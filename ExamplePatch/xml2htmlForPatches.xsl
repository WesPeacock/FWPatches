<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/TR/xhtml1/strict">
<xsl:template match="/">
  <html>
<head>
<title>Example Sentences (with highlighting)</title>
</head>
  <body>
  <h2>Example Sentences</h2>
    <table border="1">
      <tr bgcolor="#9acd32">
        <th>Lexeme</th>
        <th>Citation</th>
        <th>Variant(s)</th>
        <th>Allomorph(s)</th>
        <th>Example Sentence</th>
      </tr>
      <xsl:for-each select="LexExamplePatchSet/LexExamplePatch">
      <tr>
        <td><xsl:value-of select="LexEntText"/></td>
        <td><xsl:value-of select="LexCitationText"/></td>
        <td><xsl:value-of select="LexEntVarText"/></td>
        <td><xsl:value-of select="LexAlloText"/></td>
        <td><xsl:value-of select="ExampleText"/></td>
      </tr>
      </xsl:for-each>
    </table>
  </body>
  </html>
</xsl:template>
</xsl:stylesheet>
