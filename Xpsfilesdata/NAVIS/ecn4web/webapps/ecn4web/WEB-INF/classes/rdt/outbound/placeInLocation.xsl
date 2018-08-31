<?xml version='1.0' encoding='utf-8'?>
<!--
  ~ Copyright (c) 2012 Navis LLC. All Rights Reserved.
  ~ - a 2nd line is required by Checkstyle -
  -->

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs">

    <xsl:param name="cheId" required="yes"/>
    <xsl:param name="msid" required="yes"/>
    <xsl:param name="formId" required="yes"/>
    <xsl:param name="mode" required="no"/>
    <xsl:param name="inputValue" required="yes"/>
    <xsl:param name="inputValue2" required="no"/>
    <xsl:param name="eqId" required="yes"/>
    <xsl:param name="eqId2" required="no"/>
    <xsl:param name="tkps" required="no"/>
    <xsl:param name="tkps2" required="no"/>

    <xsl:template match="/">
        <message type="2630" MSID="{$msid}" formId="{$formId}">
            <che CHID="{$cheId}" action="C">
                <!--Only Support single containers, add JPOS to allow payload processing.-->
                <xsl:choose>
                    <xsl:when test="$mode = 'TWIN' or $mode = 'SELECTOPTION_TWIN' or $mode='REFINE_TWIN'">
                        <container EQID="{$eqId}">
                        <position PPOS="{$inputValue}" JPOS='FWD'/>
                        </container>
                        <container EQID="{$eqId2}">
                            <position PPOS="{$inputValue2}" JPOS='AFT'/>
                        </container>
                    </xsl:when>
                    <xsl:when test="$mode = 'CHASSIS' and $inputValue != ''">
                        <container EQID="{$eqId}" JPOS='CTR'>
                            <position PPOS="{$inputValue}" TKPS="{$inputValue2}"/>
                        </container>
                    </xsl:when>
                    <xsl:otherwise>
                        <container EQID="{$eqId}">
                            <position PPOS="{$inputValue}" JPOS='CTR'/>
                        </container>
                    </xsl:otherwise>
                </xsl:choose>
            </che>
        </message>
    </xsl:template>
</xsl:stylesheet>
