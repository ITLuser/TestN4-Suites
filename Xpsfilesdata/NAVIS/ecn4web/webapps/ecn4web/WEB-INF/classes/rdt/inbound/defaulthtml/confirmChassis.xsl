<?xml version='1.0' encoding="utf-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                version="2.0"
                exclude-result-prefixes="xs text">
    <xsl:import href="templates/common.xsl"/>
    <xsl:import href="templates/pagination.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" indent="yes" omit-xml-declaration="yes"
                encoding="UTF-8"/>

    <xsl:variable name="totalCount" select="/message/che/option-list/@count" as="xs:integer"/>
    <xsl:variable name="cssSytle" select="if ($totalCount != 0) then 'pagination' else 'pagination-no-border'"/>
    <xsl:variable name="items" select="/message/che/option-list/unit"/>
    <xsl:variable name="item-name" select="/message/che/option-list/@name"/>

    <xsl:variable name="mode" select="''"/>
    <xsl:variable name="maxPerPage" as="xs:integer">
        <xsl:choose>
            <xsl:when test="/message/che/option-list/@maxAllowed != ''">
                <xsl:value-of select="/message/che/option-list/@maxAllowed"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="6"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:template match='/'>
        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="text:format('title.Confirm_Chassis_Pull')"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment"/>

                    <fieldset class="{$cssSytle}">
                        <legend>
                            <span class="header">
                                <xsl:call-template name="pagination-controls">
                                    <xsl:with-param name="pagination-title">
                                        <xsl:call-template name="paginationTitle">
                                            <xsl:with-param name="items" select="$items"/>
                                            <xsl:with-param name="item-name" select="text:format('label.Equipment')"/>
                                        </xsl:call-template>
                                    </xsl:with-param>
                                </xsl:call-template>
                            </span>
                        </legend>
                        <xsl:if test="$totalCount != 0">
                            <table class="data">
                                <tbody>
                                    <xsl:apply-templates select="/message/che/option-list/unit"/>
                                </tbody>
                            </table>
                        </xsl:if>
                    </fieldset>
                    <xsl:call-template name="command-menu">
                        <xsl:with-param name="mode" select="$mode"/>
                    </xsl:call-template>
                    <xsl:call-template name="pagination-fields">
                        <xsl:with-param name="items" select="$items"/>
                    </xsl:call-template>
                    <xsl:call-template name="hidden-fields"/>

                    <xsl:if test="$totalCount = 0">
                        <!-- This value will be used for pagination -->
                        <input type="hidden" name="start" value="0"/>
                        <input type="hidden" name="pivot" value="0"/>
                    </xsl:if>

                </form>
                <xsl:call-template name="footer"/>
            </body>

        </html>
    </xsl:template>

    <xsl:variable name="index">
        <xsl:apply-templates select="$items" mode="index"/>
    </xsl:variable>

    <!--Unit rendering-->
    <xsl:template match="unit">
        <tr class="button" id="{@index}">
            <td class="line-index">
                <a href="#">
                    <xsl:value-of select="@index"/>
                </a>
            </td>
            <td>
                <xsl:value-of select="container/@EQID | tbdunit/@EQID"/>
            </td>
            <td>

                <xsl:choose>
                    <xsl:when test="container/@isTrailer = 'Y' and not(position[@type= 'from']) ">
                        <xsl:value-of select="text:format('message.Chassis')"/>
                    </xsl:when>

                    <xsl:when test="(position[@type= 'from']) and not(container/@isTrailer = 'Y')">
                        <xsl:value-of select="text:format('message.Dispatched_Container')"/>
                    </xsl:when>

                    <xsl:when test="(position[@type= 'from']) and (container/@isTrailer = 'Y')">
                        <xsl:value-of select="text:format('message.Dispatched_Chassis')"/>
                    </xsl:when>

                    <xsl:otherwise>
                        <xsl:value-of select="$item-name"/>
                    </xsl:otherwise>

                </xsl:choose>

            </td>

            <xsl:if test="$totalCount = 0">
                <input type="hidden" name="start" value="0"/>
                <input type="hidden" name="pivot" value="0"/>
            </xsl:if>

            <xsl:if test="position() = 1">
                <input type="hidden" name="start" value="{tbdunit/@EQID | container/@EQID}"/>
            </xsl:if>

            <xsl:if test="$maxPerPage = position() and  position()!=last()">

            <input type="hidden" name="pivot" value="{tbdunit/@EQID | container/@EQID}"/>
            </xsl:if>

            <xsl:if test="position()=last()">
                <input type="hidden" name="pivot" value="{tbdunit/@EQID | container/@EQID}"/>
            </xsl:if>
        </tr>
    </xsl:template>

    <!-- This index serializes all container/tbdunit items to string form: 1:TEST0000001:container, ...
        This field will be processed by the outbound message to ECN4, mapping index to ID and
        getting unit type to determine outgoing message -->
    <xsl:template match="unit" mode="index">
        <xsl:variable name="unit-id" select="tbdunit/@EQID | container/@EQID"/>
        <xsl:variable name="unit-jpos" select="tbdunit/@JPOS | container/@JPOS"/>
        <xsl:variable name="unit-type">
            <xsl:choose>
                <xsl:when test="name(container) and not(@swappableDelivery = 'Y')">c</xsl:when>
                <!-- empty delivery job -->
                <xsl:when test="name(container) and @swappableDelivery = 'Y'">e</xsl:when>
                <xsl:otherwise>t</xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="unit-from-pos">
            <xsl:choose>
                <xsl:when test="position[@type= 'from']/@TRNS != ''">
                    <xsl:value-of select="position[@type = 'from']/@TRNS"/>
                </xsl:when>
                <xsl:when test="position[@type= 'from']/@TRKL != ''">
                    <xsl:value-of select="position[@type = 'from']/@TRKL"/>
                </xsl:when>
                <xsl:when test="position[@type = 'from']/@transport != ''">
                    <xsl:value-of select="position[@type = 'from']/@transport"/>
                </xsl:when>
                <xsl:when test="position[@type = 'from']/@AREA_TYPE = 'ITV'">
                    <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position[@type = 'from']/@PPOS"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat(@index,':',$unit-id,':',$unit-type,':',$unit-jpos,':',$unit-from-pos)"/>
        <xsl:if test="position() != last()">,</xsl:if>
    </xsl:template>

</xsl:stylesheet>
