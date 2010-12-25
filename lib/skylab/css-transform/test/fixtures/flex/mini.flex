
escape    {unicode}|\\[^\n\r\f0-9a-f]
unicode   \\[0-9a-f]{1,6}(\r\n|[ \n\r\t\f])?

%%

unicode          return UNICODE;
\/\*[^*]*\*+([^/*][^*]*\*+)*\/                    /* ignore comments */
.                return *yytext;
