<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="text" />
	<xsl:decimal-format name="decimal" NaN="0" />
	
	<!-- generate keys for frequently referenced nodes -->
	<xsl:key name="table_by_uuid" match="/base/table" use="./@uuid" />
	<xsl:key name="field_by_uuid" match="/base/table/field" use="./@uuid" />	
	<xsl:key name="related_1_for_table_uuid" match="/base/relation/related_field[@kind = 'source']/field_ref/table_ref" use="@uuid" />
	<xsl:key name="related_N_for_table_uuid" match="/base/relation/related_field[@kind = 'destination']/field_ref/table_ref" use="@uuid" />

	<xsl:template match="/">
		<xsl:text>model = new DataStoreCatalog();&#xA;</xsl:text>
		<xsl:apply-templates select="/base/table" />
	</xsl:template>

	<xsl:template name="escape-string">
		<xsl:param name="s"/>
		<xsl:text>&quot;</xsl:text>
		<xsl:call-template name="escape-bs-string">
			<xsl:with-param name="s" select="$s"/>
		</xsl:call-template>
		<xsl:text>&quot;</xsl:text>
	</xsl:template>
    
	<xsl:template name="escape-js-attribute">
		<xsl:param name="s"/>
		<xsl:param name="e"/>        
		<xsl:choose>
			<xsl:when test="($e = 'true')">
				<xsl:value-of select="concat('[', &quot;&apos;&quot;)"/>
                <xsl:call-template name="escape-bs-string">
                    <xsl:with-param name="s" select="$s"/>
                </xsl:call-template>
				<xsl:value-of select="concat(&quot;&apos;&quot;, ']')"/>			
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="'.'"/>
                <xsl:call-template name="escape-bs-string">
                    <xsl:with-param name="s" select="$s"/>
                </xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>		    

	<xsl:template name="escape-bs-string">
		<xsl:param name="s"/>
		<xsl:choose>
			<xsl:when test="contains($s,'\')">
				<xsl:call-template name="escape-quot-string">
					<xsl:with-param name="s" select="concat(substring-before($s,'\'),'\\')"/>
				</xsl:call-template>
				<xsl:call-template name="escape-bs-string">
					<xsl:with-param name="s" select="substring-after($s,'\')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="escape-quot-string">
					<xsl:with-param name="s" select="$s"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	

	<xsl:template name="escape-quot-string">
		<xsl:param name="s"/>
		<xsl:choose>
			<xsl:when test="contains($s,'&quot;')">
				<xsl:choose>
					<xsl:when test="contains($s,&quot;&apos;&quot;)">
						<xsl:call-template name="encode-string">
							<xsl:with-param name="s" select="concat(substring-before($s,&quot;&apos;&quot;),&quot;\&apos;&quot;)"/>
						</xsl:call-template>
						<xsl:call-template name="escape-quot-string">
							<xsl:with-param name="s" select="substring-after($s,&quot;&apos;&quot;)"/>
						</xsl:call-template>				
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="encode-string">
							<xsl:with-param name="s" select="concat(substring-before($s,'&quot;'),'\&quot;')"/>
						</xsl:call-template>
						<xsl:call-template name="escape-quot-string">
							<xsl:with-param name="s" select="substring-after($s,'&quot;')"/>
						</xsl:call-template>	
					</xsl:otherwise>
				</xsl:choose>			
			</xsl:when>
			<xsl:when test="contains($s,&quot;&apos;&quot;)">
				<xsl:call-template name="encode-string">
					<xsl:with-param name="s" select="concat(substring-before($s,&quot;&apos;&quot;),&quot;\&apos;&quot;)"/>
				</xsl:call-template>
				<xsl:call-template name="escape-quot-string">
					<xsl:with-param name="s" select="substring-after($s,&quot;&apos;&quot;)"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="encode-string">
					<xsl:with-param name="s" select="$s"/>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="encode-string">
		<xsl:param name="s"/>
		<xsl:choose>
			<xsl:when test="contains($s,'&#x9;')">
				<xsl:call-template name="encode-string">
					<xsl:with-param name="s" select="concat(substring-before($s,'&#x9;'),'\t',substring-after($s,'&#x9;'))"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($s,'&#xA;')">
				<xsl:call-template name="encode-string">
					<xsl:with-param name="s" select="concat(substring-before($s,'&#xA;'),'\n',substring-after($s,'&#xA;'))"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="contains($s,'&#xD;')">
				<xsl:call-template name="encode-string">
					<xsl:with-param name="s" select="concat(substring-before($s,'&#xD;'),'\r',substring-after($s,'&#xD;'))"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$s"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>	
	
	<xsl:template match="/base/table">
		<xsl:variable name="pp" select="position()"/>		
			<xsl:for-each select="./field">
				<!--TABLE-->
				<xsl:if test="position() = 1">
					<xsl:text>&#xA;</xsl:text>
                    <xsl:value-of select="'model'"/>
                    <xsl:call-template name="escape-js-attribute">
                        <xsl:with-param name="s" select="../@name"/>
                        <xsl:with-param name="e" select="../@should-escape"/>
                    </xsl:call-template>
					<xsl:text> = new DataClass(</xsl:text>
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="concat(../@name, 'Collection')"/>
					</xsl:call-template>
					<xsl:text>, &quot;public&quot;);&#xA;&#xA;</xsl:text>
				</xsl:if>
				<!--FIELD-->
                <xsl:value-of select="'model'"/>
                <xsl:call-template name="escape-js-attribute">
                    <xsl:with-param name="s" select="../@name"/>
                    <xsl:with-param name="e" select="../@should-escape"/>
                </xsl:call-template>
                <xsl:call-template name="escape-js-attribute">
                    <xsl:with-param name="s" select="@name"/>
                    <xsl:with-param name="e" select="@should-escape"/>
                </xsl:call-template>    
				<xsl:text> = new Attribute(&quot;storage&quot;, </xsl:text>
				<!--FIELD TYPE-->
				<xsl:choose>
					<xsl:when test="@store_as_UUID = 'true'">
						<xsl:text>&quot;uuid&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 1">
						<xsl:text>&quot;bool&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 3">
						<xsl:text>&quot;word&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 4">
						<xsl:text>&quot;long&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 5">
						<xsl:text>&quot;long64&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 6">
						<xsl:text>&quot;number&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 7">
						<xsl:text>&quot;number&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 8">
						<xsl:text>&quot;duration&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 9">
						<xsl:text>&quot;duration&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 12">
						<xsl:text>&quot;image&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 14">
						<xsl:text>&quot;string&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 15">
						<xsl:text>&quot;long&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 16">
						<xsl:text>&quot;long&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 18">
						<xsl:text>&quot;blob&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 10">
						<xsl:text>&quot;string&quot;</xsl:text>
					</xsl:when>
				</xsl:choose>	
				<xsl:text>, </xsl:text>
				
				<xsl:variable name="c1" select="../primary_key/@field_uuid = @uuid"/>
				<xsl:variable name="c2" select="$c1 or @unique = 'true'"/>
				<xsl:variable name="c3" select="$c2 or @autosequence = 'true'"/>								
				<xsl:variable name="c4" select="$c3 or @autogenerate = 'true'"/>					
				<xsl:variable name="c5" select="$c4 or @not_null = 'true'"/>							
				<xsl:variable name="c6" select="$c5 or @styled_text = 'true'"/>
				<xsl:variable name="c7" select="$c6 or @outside_blob = 'true'"/>
				<xsl:variable name="c8" select="$c7 or @text_switch_size"/>
				<xsl:variable name="c9" select="$c8 or @blob_switch_size"/>
				<xsl:variable name="cA" select="$c9 or ./field_extra/@multi_line = 'true'"/>
				<xsl:variable name="cB" select="$cA or @limiting_length"/>
				
				<xsl:choose>
				<xsl:when test="$cB">
					<xsl:text>{</xsl:text>
					<xsl:if test="../primary_key/@field_uuid = @uuid">
						<xsl:text>&quot;primKey&quot;: true</xsl:text>
					</xsl:if>
					<xsl:if test="@unique = 'true'">
						<xsl:if test="$c1">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text>&quot;unique&quot;: true</xsl:text>
					</xsl:if>
					<xsl:if test="@autosequence = 'true'">
						<xsl:if test="$c2">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text>&quot;autosequence&quot;: true</xsl:text>
					</xsl:if>
					<xsl:if test="@autogenerate = 'true'">
						<xsl:if test="$c3">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text>&quot;autogenerate&quot;: true</xsl:text>
					</xsl:if>
					<xsl:if test="@not_null = 'true'">
						<xsl:if test="$c4">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text>&quot;not_null&quot;: true</xsl:text>
					</xsl:if>
					<xsl:if test="@styled_text = 'true'">
						<xsl:if test="$c5">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text>&quot;styled_text&quot;: true</xsl:text>
					</xsl:if>
					<xsl:if test="@outside_blob = 'true'">
						<xsl:if test="$c6">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text>&quot;outside_blob&quot;: true</xsl:text>
					</xsl:if>
					<xsl:if test="@text_switch_size">
						<xsl:if test="$c7">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text>&quot;blob_switch_size&quot;: </xsl:text>
						<xsl:value-of select="@text_switch_size"/>
					</xsl:if>
					<xsl:if test="@blob_switch_size">
						<xsl:if test="$c8">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text>&quot;blob_switch_size&quot;: </xsl:text>
						<xsl:value-of select="@blob_switch_size"/>
					</xsl:if>
					<xsl:if test="./field_extra/@multi_line = 'true'">
						<xsl:if test="$c9">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:text>&quot;multiLine&quot;: true</xsl:text>
					</xsl:if>
					<xsl:if test="@limiting_length">
						<xsl:if test="$cA">
							<xsl:text>,</xsl:text>
						</xsl:if>
						<xsl:text>&quot;limiting_length&quot;: </xsl:text>
						<xsl:value-of select="@limiting_length"/>
					</xsl:if>
							
					<!--INDEX -->
					<xsl:variable name="u" select="@uuid"/>
					<xsl:if test="/base/index/field_ref[@uuid = $u]">
						<xsl:if test="$cB">
							<xsl:text>, </xsl:text>
						</xsl:if>
						<xsl:variable name="i" select="/base/index/field_ref[@uuid = $u]/parent::node()"/>
							<xsl:choose>
								<xsl:when test="$i/@kind = 'keywords'">
									<xsl:text>&quot;indexKind&quot;: &quot;keywords&quot;</xsl:text>
								</xsl:when>
								<xsl:when test="$i/@kind = 'regular' and $i/@type = '1' ">
									<xsl:text>&quot;indexKind&quot;: &quot;btree&quot;</xsl:text>
								</xsl:when>
								<xsl:when test="$i/@kind = 'regular' and $i/@type = '3' ">
									<xsl:text>&quot;indexKind&quot;: &quot;cluster&quot;</xsl:text>				
								</xsl:when>
								<xsl:otherwise>
									<xsl:text>&quot;indexKind&quot;: &quot;auto&quot;</xsl:text>				
								</xsl:otherwise>												
							</xsl:choose>
					</xsl:if>
					<xsl:text>}</xsl:text>
				</xsl:when>	
				<xsl:otherwise>
					<xsl:text>null</xsl:text>
				</xsl:otherwise>									
				</xsl:choose>				
				<xsl:text>);&#xA;</xsl:text>
			</xsl:for-each>
			<!--RELATION(N)-->
			<xsl:if test="/base/relation/related_field[@kind = 'destination']/field_ref/table_ref">
				<xsl:for-each select="key('related_N_for_table_uuid', @uuid)">
                    <xsl:value-of select="model"/>
                    <xsl:call-template name="escape-js-attribute">
                        <xsl:with-param name="s" select="../../../related_field[@kind = 'destination']/field_ref/table_ref/@name"/>
                        <xsl:with-param name="e" select="../../../related_field[@kind = 'destination']/field_ref/table_ref/@should-escape"/>
                    </xsl:call-template>    
                    <xsl:value-of select="concat('.', ../../../@name_1toN)"/>
					<xsl:text> = new Attribute(&quot;relatedEntities&quot;, </xsl:text>
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="concat(../../../related_field[@kind = 'source']/field_ref/table_ref/@name, 'Collection')"/>
					</xsl:call-template>
					<xsl:text>, </xsl:text>
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="../../../@name_Nto1"/>
					</xsl:call-template>
					<xsl:text>, {&quot;reversePath&quot;: true});&#xA;</xsl:text>
				</xsl:for-each>
			</xsl:if>
			<!--RELATION(1)-->
			<xsl:if test="/base/relation/related_field[@kind = 'source']/field_ref/table_ref">
				<xsl:for-each select="key('related_1_for_table_uuid', @uuid)">
                    <xsl:value-of select="model"/>
                    <xsl:call-template name="escape-js-attribute">
                        <xsl:with-param name="s" select="../../../related_field[@kind = 'source']/field_ref/table_ref/@name"/>
                        <xsl:with-param name="e" select="../../../related_field[@kind = 'source']/field_ref/table_ref/@should-escape"/>
                    </xsl:call-template> 
					<xsl:value-of select="concat('.', ../../../@name_Nto1)"/>
					<xsl:text> = new Attribute(&quot;relatedEntity&quot;, </xsl:text>
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="../../../related_field[@kind = 'destination']/field_ref/table_ref/@name"/>
					</xsl:call-template>
					<xsl:text>, </xsl:text>
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="../../../related_field[@kind = 'destination']/field_ref/table_ref/@name"/>
					</xsl:call-template>
					<xsl:text>);&#xA;</xsl:text>
				</xsl:for-each>
			</xsl:if>
	</xsl:template>
			
</xsl:stylesheet>
