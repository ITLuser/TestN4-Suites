<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet xmlns:xsl='http://www.w3.org/1999/XSL/Transform' version='2.0'
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:text="http://www.navis.com/ecn4web/functions"
                exclude-result-prefixes="text">
    <xsl:import href="templates/common.xsl"/>
    <xsl:import href="templates/attributes/attribute-dictionary.xsl"/>
    <xsl:output method="xhtml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
                doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
                indent="yes" omit-xml-declaration="yes" encoding="UTF-8"/>
    <xsl:preserve-space elements="td"/>

    <xsl:variable name="PPOS">
        <xsl:choose>
            <xsl:when test="message/che/work/@moveStage != 'CARRY_UNDERWAY'">
                <xsl:value-of select="message/che/work/job[1]/position[@type = 'from']/@PPOS"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="message/che/work/job[1]/position[@type = 'to']/@PPOS"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="cheid">
        <xsl:value-of select="/message/che/@CHID"/>
    </xsl:variable>

    <xsl:template match='/'>
        <html>
            <head>
                <xsl:call-template name="header">
                    <xsl:with-param name="pageTitle" select="text:format('title.Confirm_Truck_Lane')"/>
                </xsl:call-template>
            </head>
            <body>
                <form id="xmlrdtForm" name="xmlrdtForm" action='{$contextPath}/servlet/xmlrdt' method='post'
                      accept-charset="UTF-8">
                    <xsl:call-template name="message-fragment"/>
                    <xsl:apply-templates select="/message/che/work" mode="position-type">
                        <xsl:with-param name="position-type">
                            <xsl:apply-templates select="/message/che/work/@moveStage"/>
                        </xsl:with-param>
                        <xsl:with-param name="che-in-transferZone" select="true()"/>
                    </xsl:apply-templates>
                    <div class="data">
                        <xsl:apply-templates select="/message/che/work"/>
                    </div>
                    <xsl:call-template name="command-menu"/>

                    <xsl:call-template name="hidden-fields"/>
                    <input type="hidden" name="truckId" value="{$cheid}"/>
                    <input type="hidden" name="ppos" value="{$PPOS}"/>
                </form>
                <xsl:call-template name="footer"/>
            </body>
        </html>

    </xsl:template>

    <xsl:template match="work">
        <div class="line-item">
            <xsl:choose>
                <xsl:when test="job[*]/position[@AREA_TYPE = 'YardTransTZ']">
                    <xsl:value-of select="text:format('message.Stop_at_row', $PPOS)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text:format('message.Please_Confirm_Truck_Lane',$PPOS)"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="@moveStage">
        <xsl:choose>
            <xsl:when test=". != 'CARRY_UNDERWAY'">
                <xsl:value-of select="'from'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'to'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

</xsl:stylesheet>
