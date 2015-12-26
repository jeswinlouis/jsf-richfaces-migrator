<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:ui="http://java.sun.com/jsf/facelets" xmlns:h="http://java.sun.com/jsf/html"
                xmlns:f="http://java.sun.com/jsf/core" xmlns:rich="http://richfaces.org/rich"
                xmlns:a4j="http://richfaces.org/a4j" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:s="http://jboss.org/schema/seam/taglib">

    <xsl:output
            method="xml"
            encoding="utf-8"
            doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
            doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
            indent="no"
            omit-xml-declaration="yes"
    />


    <!-- Copie totale de la page -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="head" name="head" xpath-default-namespace="http://www.w3.org/1999/xhtml">
        <h:head>
            <xsl:apply-templates select="@*|node()" />
        </h:head>
    </xsl:template>
    <xsl:template match="body" name="body" xpath-default-namespace="http://www.w3.org/1999/xhtml">
        <h:body>
            <xsl:apply-templates select="@*|node()" />
        </h:body>
    </xsl:template>

    <!-- script tag -->
    <xsl:template match="//script" priority="20" xpath-default-namespace="http://www.w3.org/1999/xhtml" >
        <xsl:element name="script" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:attribute name="type">text/javascript</xsl:attribute>
            <xsl:copy-of select="@*"/>
            <xsl:text disable-output-escaping="yes"><![CDATA[//<]]></xsl:text><xsl:text disable-output-escaping="yes">![CDATA[</xsl:text>
            <xsl:value-of select="." disable-output-escaping="yes"/>
            <xsl:text>//]]</xsl:text><xsl:text disable-output-escaping="yes"><![CDATA[>]]></xsl:text>
        </xsl:element>
    </xsl:template>

    <!-- Attributs Ajax -->
    <xsl:template match="@reRender" name="reRender" >
        <xsl:attribute name="render"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>
    <xsl:template match="@process" name="process" >
        <xsl:attribute name="execute"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>
    <xsl:template match="@limitToList" name="limitToList"  >
        <xsl:attribute name="limitRender"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>
    <!-- Supprimés -->
    <xsl:template match="@ignoreDupResponse" />
    <xsl:template match="@requestDelay" />
    <xsl:template match="@timeout" />
    <xsl:template match="@ajaxSingle" >
        <xsl:if test="..[not(@process)]" >
            <xsl:attribute name="execute"><xsl:text>@this</xsl:text></xsl:attribute>
        </xsl:if>
    </xsl:template>

    <xsl:template match="h:graphicImage" name="h:graphicImage">
        <h:graphicImage>
            <xsl:apply-templates select="@*[name()!='value']" />
            <xsl:attribute name="library">default</xsl:attribute>
            <xsl:attribute name="name">
                <xsl:value-of select="replace(./@value, '/(images/.*)\.([pngif]{3})', '$1.$2')" />
            </xsl:attribute>
            <xsl:attribute name="alt">
                <xsl:if test=".[@value]" >
                    <xsl:analyze-string select="./@value" regex="[-\.a-zA-Z_]+$">
                        <xsl:matching-substring>
                            <xsl:value-of select="." />
                        </xsl:matching-substring>
                    </xsl:analyze-string>
                </xsl:if>
            </xsl:attribute>
            <xsl:apply-templates select="node()" />
        </h:graphicImage>
    </xsl:template>

    <xsl:template match="*/@oncomplete" name="oncomplete">
        <xsl:attribute name="oncomplete">
            <xsl:value-of select="replace(., '(.*)data(.*)', '$1event.data$2')" />
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="a4j:loadScript" name="a4j:loadScript">
        <h:outputScript library="default">
            <xsl:apply-templates select="@*[name()!='src']" />
            <xsl:attribute name="library">default</xsl:attribute>
            <xsl:attribute name="name"><xsl:value-of select="replace(./@src, '/js/(.*\.js)', 'js/$1')" /></xsl:attribute>
        </h:outputScript>
    </xsl:template>

    <xsl:template match="a4j:loadStyle" name="a4j:loadStyle">
        <h:outputStylesheet >
            <xsl:apply-templates select="@*[name()!='src']" />
            <xsl:attribute name="library">default</xsl:attribute>
            <xsl:attribute name="name"><xsl:value-of select="replace(./@src, '/css/(.*\.css)', 'css/$1')"></xsl:value-of></xsl:attribute>
        </h:outputStylesheet>
    </xsl:template>

    <xsl:template match="a4j:actionparam" name="a4j:actionparam">
        <a4j:param>
            <xsl:apply-templates select="@*|node()" />
        </a4j:param>
    </xsl:template>

    <xsl:template match="a4j:support" name="a4j:support">
        <a4j:ajax>
            <xsl:apply-templates select="@*|node()" />
        </a4j:ajax>
    </xsl:template>
    <xsl:template match="a4j:support/@action">
        <xsl:attribute name="listener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>
    <xsl:template match="a4j:support/@event">
        <xsl:attribute name="event">
            <xsl:value-of select="replace( . , 'on(.*)', '$1')" />
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="a4j:commandButton/@image" name="a4j:commandButton-image">
        <xsl:attribute name="image">
            <xsl:value-of select="replace( . , '(/image.*)', '/resources/default$1')" />
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="a4j:log/@popup">
        <xsl:attribute name="mode"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="a4j:include" name="a4j:include">
        <ui:include>
            <xsl:apply-templates select="@*|node()" />
        </ui:include>
    </xsl:template>

    <xsl:template match="a4j:form" name="a4j:form">
        <h:form>
            <xsl:apply-templates select="@*|node()" />
        </h:form>
    </xsl:template>

    <!-- Supprimés
    <xsl:template match="a4j:form" />
    <xsl:template match="a4j:page"/>
    <xsl:template match="a4j:AjaxListener" /> -->

    <xsl:template match="a4j:page">
        <h:panelGroup layout="block">
            <xsl:apply-templates select="@*|node()" />
        </h:panelGroup>
    </xsl:template>

    <xsl:template match="a4j:region/@renderRegionOnly" />
    <xsl:template match="a4j:region/@selfRendered" />
    <xsl:template match="a4j:region/@ajaxListener" />
    <xsl:template match="a4j:region/@immediate" />

    <!-- Rich validation components -->

    <!-- Renommés -->
    <xsl:template match="rich:ajaxValidator" name="rich:ajaxValidator">
        <rich:validator>
            <xsl:apply-templates select="@*|node()" />
        </rich:validator>
    </xsl:template>

    <xsl:template match="rich:jQuery/@timing">
        <xsl:attribute name="timing">domready</xsl:attribute>
    </xsl:template>

    <!-- Supprimés <xsl:template match="rich:beanValidator" /> -->

    <!-- Rich input components -->

    <!-- rich:comboBox > rich:autocomplete -->
    <xsl:template match="rich:comboBox" name="rich:comboBox">
        <rich:autocomplete>
            <xsl:apply-templates select="@*|node()" />
        </rich:autocomplete>
    </xsl:template>

    <xsl:template match="rich:suggestionBox" name="rich:suggestionBox">
        <rich:autocomplete>
            <xsl:apply-templates select="@*|node()" />
        </rich:autocomplete>
    </xsl:template>

    <xsl:template match="rich:suggestionbox" name="rich:suggestionbox">
        <rich:autocomplete>
            <xsl:apply-templates select="@*|node()" />
        </rich:autocomplete>
    </xsl:template>

    <xsl:template match="rich:fileUpload/@error">
        <xsl:attribute name="serverErrorLabel"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <!-- Supprimés <xsl:template match="rich:colorPicker" /> -->
    <xsl:template match="rich:inplaceInput/@onviewactivated" />
    <xsl:template match="rich:inplaceSelect/@onviewactivated" />

    <!-- Rich Panels/output components -->

    <!-- Renommés -->
    <xsl:template match="rich:modalPanel" name="rich:modalPanel">
        <rich:popupPanel modal="true">
            <xsl:apply-templates select="@*|node()" />
        </rich:popupPanel>
    </xsl:template>

    <xsl:template match="rich:modalPanel/@showWhenRendered">
        <xsl:attribute name="show"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:panelBar" name="rich:panelBar">
        <rich:accordion>
            <xsl:apply-templates select="@*|node()" />
        </rich:accordion>
    </xsl:template>

    <xsl:template match="rich:panelBarItem" name="rich:panelBarItem">
        <rich:accordionItem>
            <xsl:apply-templates select="@*|node()" />
        </rich:accordionItem>
    </xsl:template>

    <xsl:template match="rich:panelMenu/@ValueChangeListener">
        <xsl:attribute name="itemchangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:simpleTogglePanel" name="rich:simpleTogglePanel">
        <rich:collapsiblePanel>
            <xsl:apply-templates select="@*|node()" />
        </rich:collapsiblePanel>
    </xsl:template>

    <xsl:template match="rich:tabPanel/@ValueChangeEvent">
        <xsl:attribute name="itemChangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:tabPanel/@valueChangeListener">
        <xsl:attribute name="itemChangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:tabPanel/@label">
        <xsl:attribute name="header"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:tabPanel/@selectedTab">
        <xsl:attribute name="activeItem"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:tab/@ValueChangeEvent">
        <xsl:attribute name="itemChangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:tab/@valueChangeListener">
        <xsl:attribute name="itemChangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:tab/@label">
        <xsl:attribute name="header"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:tab/@ontabenter">
        <xsl:attribute name="onheaderclick"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:togglePanel/@ValueChangeEvent">
        <xsl:attribute name="itemChangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:togglePanel/@valueChangeListener">
        <xsl:attribute name="itemChangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:facets" name="rich:facets">
        <rich:togglePanelItem>
            <xsl:apply-templates select="@*|node()" />
        </rich:togglePanelItem>
    </xsl:template>

    <xsl:template match="rich:facets/@ValueChangeEvent">
        <xsl:attribute name="itemChangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:facets/@valueChangeListener">
        <xsl:attribute name="itemChangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:toggleControl/@ValueChangeEvent">
        <xsl:attribute name="itemChangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:toggleControl/@valueChangeListener">
        <xsl:attribute name="itemChangeListener"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <!--  rich:toolBar > rich:toolbar -->
    <xsl:template match="rich:toolBar" name="rich:toolBar">
        <rich:toolbar>
            <xsl:apply-templates select="@*|node()" />
        </rich:toolbar>
    </xsl:template>

    <!--  rich:toolBarGroup > rich:toolbarGroup -->
    <xsl:template match="rich:toolBarGroup" name="rich:toolBarGroup">
        <rich:toolbarGroup>
            <xsl:apply-templates select="@*|node()" />
        </rich:toolbarGroup>
    </xsl:template>

    <!--  ToolTip > tooltip -->
    <xsl:template match="rich:toolTip" name="rich:toolTip">
        <rich:tooltip>
            <xsl:apply-templates select="@*|node()" />
        </rich:tooltip>
    </xsl:template>

    <!--  Tooltip bottom-right devien bootomRight -->
    <xsl:template match="rich:toolTip/@direction" >
        <xsl:attribute name="direction">
            <xsl:choose>
                <xsl:when test="contains(., 'right')">
                    <xsl:value-of select="replace( . , '(.*)-right', '$1Right')" />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace( . , '(.*)-left', '$1Left')" />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <!-- rich:messages Suppression des classes sur  rich messages -->
    <xsl:template match="rich:messages/@errorClass" />
    <xsl:template match="rich:messages/@infoClass" />
    <xsl:template match="rich:messages/@styleClass" name="message-styleClass">
        <xsl:attribute name="styleClass"><xsl:value-of select="." /><xsl:text> level_</xsl:text><xsl:value-of select="../@level" /></xsl:attribute>
    </xsl:template>
    <xsl:template match="rich:messages[not(@styleClass)]" >
        <rich:messages>
            <xsl:attribute name="styleClass"><xsl:text>level_</xsl:text><xsl:copy-of select="./@level" /></xsl:attribute>
            <xsl:apply-templates select="@*|node()" />
        </rich:messages>
    </xsl:template>
    <xsl:template match="rich:messages/@level" />

    <xsl:template match="rich:separator" name="rich:separator">
        <h:panelGroup>
            <xsl:attribute name="layout"><xsl:text>block</xsl:text></xsl:attribute>
            <xsl:attribute name="styleClass"><xsl:value-of select="@lineType" /><xsl:text> separator</xsl:text></xsl:attribute>
            <xsl:attribute name="style"><xsl:value-of select="@style" /><xsl:text>;height:</xsl:text><xsl:value-of select="@height" /></xsl:attribute>
        </h:panelGroup>
    </xsl:template>

    <xsl:template match="rich:spacer" name="rich:spacer">
        <h:panelGroup>
            <xsl:attribute name="layout"><xsl:text>block</xsl:text></xsl:attribute>
            <xsl:attribute name="styleClass"><xsl:text>spacer</xsl:text></xsl:attribute>
        </h:panelGroup>
    </xsl:template>
    <!-- Supprimés <xsl:template match="rich:paint2D" /> <xsl:template match="rich:separator"
        /> <xsl:template match="rich:spacer" /> -->

    <!-- Rich Ordering Components -->

    <!-- Renommés -->

    <xsl:template match="rich:listShuttle" name="rich:listShuttle">
        <rich:pickList>
            <xsl:apply-templates select="@*|node()" />
        </rich:pickList>
    </xsl:template>

    <xsl:template match="rich:contextMenu/@event">
        <xsl:attribute name="showEvent"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:contextMenu/@attachTo">
        <xsl:attribute name="target"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:contextMenu/@submitMode">
        <xsl:attribute name="mode"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:menuGroup/@value" >
        <xsl:attribute name="label" ><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:menuItem/@value">
        <xsl:attribute name="label"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>
    <xsl:template match="rich:menuItem/@submitMode">
        <xsl:attribute name="mode">
            <xsl:choose>
                <xsl:when test=". = 'none'">client</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:menuItem/@icon">
        <xsl:attribute name="icon">
            <xsl:value-of select="replace( . , '(/image.*)', '/resources/default$1')" />
        </xsl:attribute>
    </xsl:template>

    <!-- Rich Iteration Components -->

    <!-- Renommés -->
    <xsl:template match="rich:dataOrderingList" name="rich:dataOrderingList">
        <rich:list>
            <xsl:apply-templates select="@*|node()" />
        </rich:list>
    </xsl:template>

    <xsl:template match="rich:dataDefinitionList" name="rich:dataDefinitionList">
        <rich:list>
            <xsl:apply-templates select="@*|node()" />
        </rich:list>
    </xsl:template>

    <xsl:template match="rich:dataList" name="rich:dataList">
        <rich:list>
            <xsl:apply-templates select="@*|node()" />
        </rich:list>
    </xsl:template>

    <xsl:template match="rich:datascroller" name="rich:datascroller">
        <rich:dataScroller>
            <xsl:apply-templates select="@*|node()" />
        </rich:dataScroller>
    </xsl:template>

    <xsl:template match="rich:datascroller/@onclick" >
        <xsl:attribute name="onbegin"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>
    <xsl:template match="rich:scrollableDataTable" name="rich:scrollableDataTable">
        <rich:extendedDataTable>
            <xsl:apply-templates select="@*|node()" />
        </rich:extendedDataTable>
    </xsl:template>
    <xsl:template match="rich:scrollableDataTable/@rows" name="rich:scrollableDataTableRows">
        <xsl:attribute name="clientRows"><xsl:value-of select="." /> </xsl:attribute>
    </xsl:template>
    <xsl:template match="rich:scrollableDataTable/@onRowDblClick" name="rich:scrollableDataTableRows1">
        <xsl:attribute name="onrowdblclick"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>
    <xsl:template match="rich:scrollableDataTable/@onRowClick" name="rich:scrollableDataTableRows2">
        <xsl:attribute name="onrowclick"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <!--  apparamment width est toujours d'actualité -->
    <!-- 	<xsl:template match="rich:column/@style" name="rich:column1"> -->
    <!-- 		<xsl:attribute name="style"> -->
    <!-- 			<xsl:value-of select="." /><xsl:text>;width:</xsl:text><xsl:value-of select="../@width" /> -->
    <!-- 			<xsl:if test="not(contains(../@width, 'px'))">px</xsl:if> -->
    <!-- 		</xsl:attribute> -->
    <!-- 	</xsl:template> -->
    <!-- 	<xsl:template match="rich:column[not(@style)]" name="rich:column2"> -->
    <!-- 		<rich:column> -->
    <!-- 			<xsl:attribute name="style">width:<xsl:value-of select="./@width" />px</xsl:attribute> -->
    <!-- 			<xsl:apply-templates select="@*[name() != 'width']|node()" /> -->
    <!-- 		</rich:column> -->
    <!-- 	</xsl:template> -->

    <!-- Supprimés To Do <xsl:template match="rich:columns" /> <xsl:template match="rich:dataFilterSlider"
        /> <xsl:template match="rich:subTable" /> -->

    <!-- Rich Tree Components -->

    <!-- Renommés -->
    <xsl:template match="rich:treeNodesAdaptor" name="rich:treeNodesAdaptor">
        <rich:treeModelAdaptor>
            <xsl:apply-templates select="@*|node()" />
        </rich:treeModelAdaptor>
    </xsl:template>

    <xsl:template match="rich:recursiveTreeNodesAdaptor" name="rich:recursiveTreeNodesAdaptor">
        <rich:treeModelRecursiveAdaptor>
            <xsl:apply-templates select="@*|node()" />
        </rich:treeModelRecursiveAdaptor>
    </xsl:template>

    <xsl:template match="rich:tree" name="rich:tree">
        <rich:tree>
            <xsl:apply-templates select="@*|node()" />
        </rich:tree>
    </xsl:template>

    <xsl:template match="rich:tree/@nodeFace">
        <xsl:attribute name="nodeType"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:tree/@switchType">
        <xsl:attribute name="toggleType"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <xsl:template match="rich:tree/@treeNodeVar">
        <xsl:attribute name="var"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <!-- Rich Miscellaneous Components -->

    <!-- Renommés -->

    <xsl:template match="rich:componentControl/@for">
        <xsl:attribute name="target"><xsl:value-of select="." /></xsl:attribute>
    </xsl:template>

    <!-- Supprimés <xsl:template match="rich:effect" /> <xsl:template match="rich:gmap"
        /> <xsl:template match="rich:insert" /> <xsl:template match="rich:page" /> <xsl:template
        match="rich:components" /> <xsl:template match="rich:virtualEarth" /> -->
</xsl:stylesheet>