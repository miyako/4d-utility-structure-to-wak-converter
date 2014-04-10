<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="text" />
	<xsl:decimal-format name="decimal" NaN="0" />

	<xsl:param name="version" select="2" />
    <xsl:param name="scriptMode" select="'manual'" />
    
	<!-- generate keys for frequently referenced nodes -->
	<xsl:key name="table_by_uuid" match="/base/table" use="./@uuid" />
	<xsl:key name="field_by_uuid" match="/base/table/field" use="./@uuid" />	
	<xsl:key name="related_1_for_table_uuid" match="/base/relation/related_field[@kind = 'source']/field_ref/table_ref" use="@uuid" />
	<xsl:key name="related_N_for_table_uuid" match="/base/relation/related_field[@kind = 'destination']/field_ref/table_ref" use="@uuid" />
	
	<xsl:template match="/">
	
		<xsl:text>{&#xA;</xsl:text>
		<xsl:text>&#x9;&quot;toJSON&quot;: true</xsl:text>
		<xsl:text>,&#xA;&#x9;&quot;dbInfo&quot;: [{&#xA;</xsl:text>	
		<xsl:text>&#x9;&#x9;&quot;name&quot;: </xsl:text>	
		<xsl:call-template name="escape-string">
			<xsl:with-param name="s" select="/base/@name"/>
		</xsl:call-template>
		<xsl:text>,&#xA;&#x9;&#x9;&quot;uuid&quot;: </xsl:text>
		<xsl:call-template name="escape-string">
			<xsl:with-param name="s" select="/base/@uuid"/>
		</xsl:call-template>
		<xsl:text>&#xA;&#x9;}]</xsl:text>							
		<xsl:text>,&#xA;&#x9;&quot;extraProperties&quot;: {&#xA;</xsl:text>
		<xsl:text>&#x9;&#x9;&quot;version&quot;: &quot;</xsl:text>
		<xsl:value-of select="$version"/>
		<xsl:text>&quot;,&#xA;</xsl:text>
		<xsl:text>&#x9;&#x9;&quot;classes&quot;: {&#xA;</xsl:text>
		<xsl:text>&#x9;&#x9;},&#xA;</xsl:text>		
		<xsl:text>&#x9;&#x9;&quot;model&quot;: {&#xA;</xsl:text>
        <xsl:text>&#x9;&#x9;&#x9;&quot;scriptMode&quot;: &quot;</xsl:text><xsl:value-of select="$scriptMode"/><xsl:text>&quot;,&#xA;</xsl:text>  
        <xsl:text>&#x9;&#x9;&#x9;&quot;workspaceLeft&quot;: 0,&#xA;</xsl:text> 
        <xsl:text>&#x9;&#x9;&#x9;&quot;workspaceTop&quot;: 0&#xA;</xsl:text> 
        <xsl:text>&#x9;&#x9;}&#xA;</xsl:text>
		<xsl:text>&#x9;},&#xA;</xsl:text>		
		<xsl:text>&#x9;&quot;dataClasses&quot;: []&#xA;</xsl:text>
		<xsl:text>}&#xA;</xsl:text>
	</xsl:template>

	<xsl:template name="model">
		<xsl:text>&#x9;&#x9;}</xsl:text>
		<xsl:text>,&#xA;&#x9;&#x9;&quot;model&quot;: {&#xA;</xsl:text>
		<xsl:text>&#x9;&#x9;&#x9;&quot;workspaceLeft&quot;: 0</xsl:text>	
		<xsl:text>,&#xA;&#x9;&#x9;&#x9;&quot;workspaceTop&quot;: 0</xsl:text>			
		<xsl:text>&#xA;&#x9;&#x9;}&#xA;</xsl:text>	
		<xsl:text>&#x9;},&#xA;</xsl:text>
	</xsl:template>

	<xsl:template name="escape-string">
		<xsl:param name="s"/>
		<xsl:text>&quot;</xsl:text>
		<xsl:call-template name="escape-bs-string">
			<xsl:with-param name="s" select="$s"/>
		</xsl:call-template>
		<xsl:text>&quot;</xsl:text>
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

	<xsl:template match="/base/table" mode="classes">
		<xsl:variable name="pp" select="position()"/>		
		<xsl:choose>
			<xsl:when test="$pp = 1">
				<xsl:text>&#x9;&#x9;&quot;classes&quot;: {&#xA;</xsl:text>
			</xsl:when>
			<xsl:otherwise>
				<xsl:text>,&#xA;</xsl:text>
			</xsl:otherwise>		
		</xsl:choose>
		<xsl:text>&#x9;&#x9;&#x9;</xsl:text>
		<xsl:call-template name="escape-string">
			<xsl:with-param name="s" select="@name"/>
		</xsl:call-template>
		<xsl:text>: {&#xA;</xsl:text>	
		<xsl:text>&#x9;&#x9;&#x9;&#x9;&quot;panelColor&quot;: </xsl:text>
		<xsl:choose>		
			<xsl:when test="number(./table_extra/editor_table_info/color/@alpha) = 0">
				<xsl:text>&quot;#C3D69B&quot;</xsl:text><!--DEFAULT COLOR-->
			</xsl:when>	
			<xsl:otherwise>
				<xsl:value-of select="concat('&quot;rgb(', ./table_extra/editor_table_info/color/@red, ',', ./table_extra/editor_table_info/color/@green, ',', ./table_extra/editor_table_info/color/@blue, ')&quot;')"/>
			</xsl:otherwise>				
		</xsl:choose>
		<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&quot;panel&quot;: {</xsl:text>
		<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;isOpen&quot;: &quot;true&quot;</xsl:text>
		<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;pathVisible&quot;: &quot;true&quot;</xsl:text>
		<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;position&quot;: {</xsl:text>
		<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;X&quot;: </xsl:text>
		<xsl:value-of select="round(./table_extra/editor_table_info/coordinates/@left)"/>
		<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;Y&quot;: </xsl:text>
		<xsl:value-of select="round(./table_extra/editor_table_info/coordinates/@top)"/>
		<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;}</xsl:text>
		<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;}</xsl:text>
		<xsl:if test="./table_extra/comment[@format = 'text']">
			<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&quot;note&quot;: </xsl:text>
			<xsl:call-template name="escape-string">
			<xsl:with-param name="s" select="./table_extra/comment[@format = 'text']"/>
		</xsl:call-template>
		</xsl:if>
		<xsl:if test="./field/field_extra/comment[@format = 'text']">
		<xsl:for-each select="./field/field_extra/comment[@format = 'text']">
				<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&quot;attributes&quot;: {</xsl:text>
				<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;</xsl:text>
				<xsl:call-template name="escape-string">
					<xsl:with-param name="s" select="../../@name"/>
				</xsl:call-template>
				<xsl:text>: {</xsl:text>
				<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;note&quot;: </xsl:text>
				<xsl:call-template name="escape-string">
					<xsl:with-param name="s" select="."/>
				</xsl:call-template>
				<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;}</xsl:text>
			</xsl:for-each> 
			<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;}</xsl:text>
		</xsl:if>
		<xsl:text>&#xA;&#x9;&#x9;&#x9;}</xsl:text>
		<xsl:if test="$pp = last()">
			<xsl:text>&#xA;</xsl:text>
		</xsl:if>
	</xsl:template>	
	
	<xsl:template match="/base/table">
		<xsl:variable name="pp" select="position()"/>		
			<xsl:for-each select="./field">
				<!--TABLE-->
				<xsl:choose>
					<xsl:when test="position() = 1">
						<xsl:choose>
							<xsl:when test="$pp != 1">
								<xsl:text>,&#xA;</xsl:text>
							</xsl:when>
							<xsl:otherwise>
								<xsl:text>&#x9;&quot;dataClasses&quot;: [&#xA;</xsl:text>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="position() != 1">
							<xsl:text>,&#xA;</xsl:text>
						</xsl:if> 
						<xsl:text>&#x9;&#x9;{&#xA;</xsl:text>
						<xsl:text>&#x9;&#x9;&#x9;&quot;name&quot;: </xsl:text>			
						<xsl:call-template name="escape-string">
							<xsl:with-param name="s" select="../@name"/>
						</xsl:call-template>
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&quot;className&quot;: </xsl:text>			
						<xsl:call-template name="escape-string">
							<xsl:with-param name="s" select="../@name"/>
						</xsl:call-template>
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&quot;collectionName&quot;: </xsl:text>			
						<xsl:call-template name="escape-string">
							<xsl:with-param name="s" select="concat(../@name, 'Collection')"/>
						</xsl:call-template>
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&quot;scope&quot;: &quot;public&quot;</xsl:text>	
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&quot;attributes&quot;: [&#xA;</xsl:text>	
						<xsl:text>&#x9;&#x9;&#x9;&#x9;{&#xA;</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;{&#xA;</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				<!--FIELD-->
				<xsl:text>&#x9;&#x9;&#x9;&#x9;&#x9;&quot;name&quot;: </xsl:text>	
				<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="@name"/>
					</xsl:call-template>
				<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;kind&quot;: &quot;storage&quot;</xsl:text>
				<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;scope&quot;: &quot;public&quot;</xsl:text>
				<!--FIELD TYPE-->
				<xsl:choose>
					<xsl:when test="@store_as_UUID = 'true'">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;uuid&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 1">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;bool&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 3">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;word&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 4">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;long&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 5">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;long64&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 6">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;number&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 7">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;number&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 8">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;date&quot;</xsl:text>
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;simpleDate&quot;: &quot;true&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 9">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;duration&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 12">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;image&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 14">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;string&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 15">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;long&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 16">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;long&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 18">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;blob&quot;</xsl:text>
					</xsl:when>
					<xsl:when test="@type = 10">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: &quot;string&quot;</xsl:text>
					</xsl:when>
				</xsl:choose>
				<xsl:if test="../primary_key/@field_uuid = @uuid">
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;primKey&quot;: &quot;true&quot;</xsl:text>
				</xsl:if>
				<xsl:if test="@unique = 'true'">
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;unique&quot;: &quot;true&quot;</xsl:text>
				</xsl:if>
				<xsl:if test="@autosequence = 'true'">
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;autosequence&quot;: &quot;true&quot;</xsl:text>
				</xsl:if>				
				<xsl:if test="@autogenerate = 'true'">
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;autogenerate&quot;: &quot;true&quot;</xsl:text>
				</xsl:if>
				<xsl:if test="@not_null = 'true'">
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;not_null&quot;: &quot;true&quot;</xsl:text>
				</xsl:if>
				<xsl:if test="@styled_text = 'true'">
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;styled_text&quot;: &quot;true&quot;</xsl:text>
				</xsl:if>
				<xsl:if test="@outside_blob = 'true'">
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;outside_blob&quot;: &quot;true&quot;</xsl:text>
				</xsl:if>
				<xsl:if test="@text_switch_size">
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;blob_switch_size&quot;: &quot;</xsl:text>
					<xsl:value-of select="@text_switch_size"/>
					<xsl:text>&quot;</xsl:text>
				</xsl:if>
				<xsl:if test="@blob_switch_size">
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;blob_switch_size&quot;: &quot;</xsl:text>
					<xsl:value-of select="@blob_switch_size"/>
					<xsl:text>&quot;</xsl:text>
				</xsl:if>				
				<xsl:if test="./field_extra/@multi_line">
					<xsl:if test="./field_extra/@multi_line = 'true'">
						<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;multiLine&quot;: &quot;true&quot;</xsl:text>
					</xsl:if>	
				</xsl:if>
				<xsl:if test="@limiting_length">
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;limiting_length&quot;: &quot;</xsl:text>
					<xsl:value-of select="@limiting_length"/>
					<xsl:text>&quot;</xsl:text>
				</xsl:if>
				<!--INDEX -->
				<xsl:variable name="u" select="@uuid"/>
				<xsl:if test="/base/index/field_ref[@uuid = $u]">
				<xsl:variable name="i" select="/base/index/field_ref[@uuid = $u]/parent::node()"/>
					<xsl:choose>
						<xsl:when test="$i/@kind = 'keywords'">
							<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;indexKind&quot;: &quot;keywords&quot;</xsl:text>	
						</xsl:when>
						<xsl:when test="$i/@kind = 'regular' and $i/@type = '1' ">
							<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;indexKind&quot;: &quot;btree&quot;</xsl:text>
						</xsl:when>
						<xsl:when test="$i/@kind = 'regular' and $i/@type = '3' ">
							<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;indexKind&quot;: &quot;cluster&quot;</xsl:text>				
						</xsl:when>
						<xsl:otherwise>
							<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;indexKind&quot;: &quot;auto&quot;</xsl:text>		
						</xsl:otherwise>												
					</xsl:choose>
				</xsl:if>
				<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;}</xsl:text>
			</xsl:for-each>
			<!--RELATION(N)-->
			<xsl:if test="/base/relation/related_field[@kind = 'destination']/field_ref/table_ref">
				<xsl:for-each select="key('related_N_for_table_uuid', @uuid)">
					<xsl:if test="not(./field)">
						<xsl:text>,&#xA;</xsl:text>
					</xsl:if>
					<xsl:text>&#x9;&#x9;&#x9;&#x9;{&#xA;</xsl:text>
					<xsl:text>&#x9;&#x9;&#x9;&#x9;&#x9;&quot;name&quot;: </xsl:text>			
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="../../../@name_1toN"/>
					</xsl:call-template>	
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: </xsl:text>	
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="concat(../../../related_field[@kind = 'source']/field_ref/table_ref/@name, 'Collection')"/>
					</xsl:call-template>	
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;path&quot;: </xsl:text>		
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="../../../@name_Nto1"/>
					</xsl:call-template>	
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;kind&quot;: &quot;relatedEntities&quot;</xsl:text>
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;reversePath&quot;: &quot;true&quot;</xsl:text>	
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;scope&quot;: &quot;public&quot;</xsl:text>	
					<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;}</xsl:text>
				</xsl:for-each>
			</xsl:if>
			
			<!--RELATION(1)-->
			<xsl:if test="/base/relation/related_field[@kind = 'source']/field_ref/table_ref">
				<xsl:for-each select="key('related_1_for_table_uuid', @uuid)">
					<xsl:if test="not(./field)">
						<xsl:text>,&#xA;</xsl:text>
					</xsl:if>
					<xsl:text>&#x9;&#x9;&#x9;&#x9;{&#xA;</xsl:text>
					<xsl:text>&#x9;&#x9;&#x9;&#x9;&#x9;&quot;name&quot;: </xsl:text>			
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="../../../@name_Nto1"/>
					</xsl:call-template>	
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;type&quot;: </xsl:text>	
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="../../../related_field[@kind = 'destination']/field_ref/table_ref/@name"/>
					</xsl:call-template>	
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;path&quot;: </xsl:text>		
					<xsl:call-template name="escape-string">
						<xsl:with-param name="s" select="../../../related_field[@kind = 'destination']/field_ref/table_ref/@name"/>
					</xsl:call-template>	
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;kind&quot;: &quot;relatedEntity&quot;</xsl:text>	
					<xsl:text>,&#xA;&#x9;&#x9;&#x9;&#x9;&#x9;&quot;scope&quot;: &quot;public&quot;</xsl:text>	
					<xsl:text>&#xA;&#x9;&#x9;&#x9;&#x9;}</xsl:text>
				</xsl:for-each>
			</xsl:if>

			<xsl:text>&#xA;&#x9;&#x9;&#x9;]</xsl:text>
			
			<xsl:if test="./primary_key">
				<xsl:text>,&#xA;&#x9;&#x9;&#x9;&quot;primKey&quot;: </xsl:text>
				<xsl:call-template name="escape-string">
					<xsl:with-param name="s" select="./primary_key/@field_name"/>
				</xsl:call-template>
			</xsl:if>
			
			<xsl:text>&#xA;&#x9;&#x9;}</xsl:text>
			<xsl:if test="$pp = last()">
				<xsl:text>&#xA;&#x9;]&#xA;</xsl:text>
			</xsl:if>
	</xsl:template>
			
</xsl:stylesheet>
