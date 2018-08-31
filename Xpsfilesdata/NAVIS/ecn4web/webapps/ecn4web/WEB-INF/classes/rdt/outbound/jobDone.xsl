<?xml version='1.0' encoding="utf-8"?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="eqId" required="yes"/>
    <xsl:param name="eqId2" required="no"/>
    <xsl:param name="mode" required="no"/>
    <xsl:param name="pposTo" select="''" required="no"/>
    <xsl:param name="pposTo2" select="''" required="no"/>
    <xsl:param name="chassis" select="''" required="no"/>
    <xsl:param name="tkps" required="no"/>
    <xsl:param name="tkps2" required="no"/>

    <xsl:template match="/">
        <message MSID="{$msid}" type="2630" formId="{$formId}">
            <che CHID="{$cheId}" action="C">
                <xsl:choose>
                    <xsl:when test="$mode = 'TWIN' or $mode = 'SELECTOPTION_TWIN'">
                        <container EQID="{$eqId}" JPOS='FWD'/>
                        <container EQID="{$eqId2}" JPOS='AFT'/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$chassis !='' and $pposTo != ''">
                                <container EQID="{$eqId}" JPOS='CTR'>
                                    <position PPOS="{$pposTo}" CHASSIS="{$chassis}" TKPS="{$tkps}"/>
                                </container>
                            </xsl:when>
                            <xsl:when test="$mode = 'CHASSIS' and $pposTo != ''">
                                <container EQID="{$eqId}" JPOS='CTR'>
                                    <position PPOS="{$pposTo}" TKPS="{$tkps}"/>
                                </container>
                            </xsl:when>
                            <xsl:otherwise>
                                <container EQID="{$eqId}" JPOS='CTR'/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </che>
        </message>
    </xsl:template>

</xsl:stylesheet>
