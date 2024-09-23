// just docs: Named Character Entities
/++





$(PRE $(CLASS GRAMMAR)
$(B $(ID NamedCharacterEntity) NamedCharacterEntity):
    $(B &) $(LINK2 lex#Identifier, Identifier) $(B ;)

)

        The full list of named character entities from the
        $(LINK2 https://w3.org/TR/html5/syntax.html#named-character-references, HTML 5 Spec)
        is supported.
        Named entities which contain multiple code points can only be used in string literals,
        not in character literals, since they do not fit in any character type.
        Below is a $(I partial) list of the named character entities.
        

        $(B Note:) Not all glyphs will display properly in the $(B Glyph)
        column in all browsers.
        

        $(TABLE_ROWS
Named Character Entities
    * + Name
+ Value
+ Glyph
    * - `quot`
- 34
- $( UNDEFINED: QUOT)

   * - `amp`
- 38
- &

   * - `lt`
- 60
- `&lt;`

   * - `gt`
- 62
- `&gt;`


   * - `OElig`
- 338
- $( UNDEFINED: OELIG_CAP)

   * - `oelig`
- 339
- $( UNDEFINED: OELIG)

   * - `Scaron`
- 352
- $( UNDEFINED: SCARON_CAP)

   * - `scaron`
- 353
- $( UNDEFINED: SCARON)

   * - `Yuml`
- 376
- $( UNDEFINED: YUML)

   * - `circ`
- 710
- $( UNDEFINED: CIRC)

   * - `tilde`
- 732
- $( UNDEFINED: TILDE)

   * - `ensp`
- 8194
- $( UNDEFINED: ENSP)

   * - `emsp`
- 8195
- $( UNDEFINED: EMSP)

   * - `thinsp`
- 8201
- $( UNDEFINED: THINSP)

   * - `zwnj`
- 8204
- $( UNDEFINED: ZWNJ)

   * - `zwj`
- 8205
- $( UNDEFINED: ZWJ)

   * - `lrm`
- 8206
- $( UNDEFINED: LRM)

   * - `rlm`
- 8207
- $( UNDEFINED: RLM)

   * - `ndash`
- 8211
- -

   * - `mdash`
- 8212
- $( UNDEFINED: MDASH)

   * - `lsquo`
- 8216
- '

   * - `rsquo`
- 8217
- '

   * - `sbquo`
- 8218
- $( UNDEFINED: SBQUO)

   * - `ldquo`
- 8220
- $( UNDEFINED: LDQUO)

   * - `rdquo`
- 8221
- $( UNDEFINED: RDQUO)

   * - `bdquo`
- 8222
- $( UNDEFINED: BDQUO)

   * - `dagger`
- 8224
- $( UNDEFINED: DAGGER)

   * - `Dagger`
- 8225
- $( UNDEFINED: DAGGER_CAP)

   * - `permil`
- 8240
- $( UNDEFINED: PERMIL)

   * - `lsaquo`
- 8249
- $( UNDEFINED: LSAQUO)

   * - `rsaquo`
- 8250
- $( UNDEFINED: RSAQUO)

   * - `euro`
- 8364
- $( UNDEFINED: EURO)

)

<br>

   $(TABLE_ROWS
Latin-1 (ISO-8859-1) Entities
   * + Name
+ Value
+ Glyph
    * - `nbsp`
- 160
- $(NBSP)

   * - `iexcl`
- 161
- $( UNDEFINED: IEXCL)

   * - `cent`
- 162
- $( UNDEFINED: CENT)

   * - `pound`
- 163
- $( UNDEFINED: POUND)

   * - `curren`
- 164
- $( UNDEFINED: CURREN)

   * - `yen`
- 165
- $( UNDEFINED: YEN)

   * - `brvbar`
- 166
- $( UNDEFINED: BRVBAR)

   * - `sect`
- 167
- $( UNDEFINED: SECT)

   * - `uml`
- 168
- $( UNDEFINED: UML)

   * - `copy`
- 169
- $( UNDEFINED: COPY)

   * - `ordf`
- 170
- $( UNDEFINED: ORDF)

   * - `laquo`
- 171
- $( UNDEFINED: LAQUO)

   * - `not`
- 172
- $( UNDEFINED: NOT)

   * - `shy`
- 173
- 

   * - `reg`
- 174
- $( UNDEFINED: REG)

   * - `macr`
- 175
- $( UNDEFINED: MACR)

   * - `deg`
- 176
- $( UNDEFINED: DEG)

   * - `plusmn`
- 177
- $(PLUSMN)

   * - `sup2`
- 178
- $( UNDEFINED: SUP2)

   * - `sup3`
- 179
- $( UNDEFINED: SUP3)

   * - `acute`
- 180
- $( UNDEFINED: ACUTE)

   * - `micro`
- 181
- $( UNDEFINED: MICRO)

   * - `para`
- 182
- $( UNDEFINED: PARA)

   * - `middot`
- 183
- $( UNDEFINED: MIDDOT)

   * - `cedil`
- 184
- $( UNDEFINED: CEDIL)

   * - `sup1`
- 185
- $( UNDEFINED: SUP1)

   * - `ordm`
- 186
- $( UNDEFINED: ORDM)

   * - `raquo`
- 187
- $( UNDEFINED: RAQUO)

   * - `frac14`
- 188
- $( UNDEFINED: FRAC14)

   * - `frac12`
- 189
- $( UNDEFINED: FRAC12)

   * - `frac34`
- 190
- $( UNDEFINED: FRAC34)

   * - `iquest`
- 191
- $( UNDEFINED: IQUEST)

   * - `Agrave`
- 192
- $( UNDEFINED: AGRAVE_CAP)

   * - `Aacute`
- 193
- $( UNDEFINED: AACUTE_CAP)

   * - `Acirc`
- 194
- $( UNDEFINED: ACIRC_CAP)

   * - `Atilde`
- 195
- $( UNDEFINED: ATILDE_CAP)

   * - `Auml`
- 196
- $( UNDEFINED: AUML_CAP)

   * - `Aring`
- 197
- $( UNDEFINED: ARING_CAP)

   * - `AElig`
- 198
- $( UNDEFINED: AELIG_CAP)

   * - `Ccedil`
- 199
- $( UNDEFINED: CCEDIL_CAP)

   * - `Egrave`
- 200
- $( UNDEFINED: EGRAVE_CAP)

   * - `Eacute`
- 201
- $( UNDEFINED: EACUTE_CAP)

   * - `Ecirc`
- 202
- $( UNDEFINED: ECIRC_CAP)

   * - `Euml`
- 203
- $( UNDEFINED: EUML_CAP)

   * - `Igrave`
- 204
- $( UNDEFINED: IGRAVE_CAP)

   * - `Iacute`
- 205
- $( UNDEFINED: IACUTE_CAP)

   * - `Icirc`
- 206
- $( UNDEFINED: ICIRC_CAP)

   * - `Iuml`
- 207
- $( UNDEFINED: IUML_CAP)

   * - `ETH`
- 208
- $( UNDEFINED: ETH_CAP)

   * - `Ntilde`
- 209
- $( UNDEFINED: NTILDE_CAP)

   * - `Ograve`
- 210
- $( UNDEFINED: OGRAVE_CAP)

   * - `Oacute`
- 211
- $( UNDEFINED: OACUTE_CAP)

   * - `Ocirc`
- 212
- $( UNDEFINED: OCIRC_CAP)

   * - `Otilde`
- 213
- $( UNDEFINED: OTILDE_CAP)

   * - `Ouml`
- 214
- $( UNDEFINED: OUML_CAP)

   * - `times`
- 215
- X

   * - `Oslash`
- 216
- $( UNDEFINED: OSLASH_CAP)

   * - `Ugrave`
- 217
- $( UNDEFINED: UGRAVE_CAP)

   * - `Uacute`
- 218
- $( UNDEFINED: UACUTE_CAP)

   * - `Ucirc`
- 219
- $( UNDEFINED: UCIRC_CAP)

   * - `Uuml`
- 220
- $( UNDEFINED: UUML_CAP)

   * - `Yacute`
- 221
- $( UNDEFINED: YACUTE_CAP)

   * - `THORN`
- 222
- $( UNDEFINED: THORN_CAP)

   * - `szlig`
- 223
- $( UNDEFINED: SZLIG)

   * - `agrave`
- 224
- $( UNDEFINED: AGRAVE)

   * - `aacute`
- 225
- $( UNDEFINED: AACUTE)

   * - `acirc`
- 226
- $( UNDEFINED: ACIRC)

   * - `atilde`
- 227
- $( UNDEFINED: ATILDE)

   * - `auml`
- 228
- $( UNDEFINED: AUML)

   * - `aring`
- 229
- $( UNDEFINED: ARING)

   * - `aelig`
- 230
- $( UNDEFINED: AELIG)

   * - `ccedil`
- 231
- $( UNDEFINED: CCEDIL)

   * - `egrave`
- 232
- $( UNDEFINED: EGRAVE)

   * - `eacute`
- 233
- $( UNDEFINED: EACUTE)

   * - `ecirc`
- 234
- $( UNDEFINED: ECIRC)

   * - `euml`
- 235
- $( UNDEFINED: EUML)

   * - `igrave`
- 236
- $( UNDEFINED: IGRAVE)

   * - `iacute`
- 237
- $( UNDEFINED: IACUTE)

   * - `icirc`
- 238
- $( UNDEFINED: ICIRC)

   * - `iuml`
- 239
- $( UNDEFINED: IUML)

   * - `eth`
- 240
- $( UNDEFINED: ETH)

   * - `ntilde`
- 241
- $( UNDEFINED: NTILDE)

   * - `ograve`
- 242
- $( UNDEFINED: OGRAVE)

   * - `oacute`
- 243
- $( UNDEFINED: OACUTE)

   * - `ocirc`
- 244
- $( UNDEFINED: OCIRC)

   * - `otilde`
- 245
- $( UNDEFINED: OTILDE)

   * - `ouml`
- 246
- $( UNDEFINED: OUML)

   * - `divide`
- 247
- $( UNDEFINED: DIVIDE)

   * - `oslash`
- 248
- $( UNDEFINED: OSLASH)

   * - `ugrave`
- 249
- $( UNDEFINED: UGRAVE)

   * - `uacute`
- 250
- $( UNDEFINED: UACUTE)

   * - `ucirc`
- 251
- $( UNDEFINED: UCIRC)

   * - `uuml`
- 252
- $( UNDEFINED: UUML)

   * - `yacute`
- 253
- $( UNDEFINED: YACUTE)

   * - `thorn`
- 254
- $( UNDEFINED: THORN)

   * - `yuml`
- 255
- $( UNDEFINED: YUML)

)

<br>

   $(TABLE_ROWS
Symbols and Greek letter entities
   * + Name
+ Value
+ Glyph
    * - `fnof`
- 402
- $( UNDEFINED: FNOF)

   * - `Alpha`
- 913
- $( UNDEFINED: ALPHA_CAP)

   * - `Beta`
- 914
- $( UNDEFINED: BETA_CAP)

   * - `Gamma`
- 915
- $( UNDEFINED: GAMMA_CAP)

   * - `Delta`
- 916
- $( UNDEFINED: DELTA_CAP)

   * - `Epsilon`
- 917
- $( UNDEFINED: EPSILON_CAP)

   * - `Zeta`
- 918
- $( UNDEFINED: ZETA_CAP)

   * - `Eta`
- 919
- $( UNDEFINED: ETA_CAP)

   * - `Theta`
- 920
- $( UNDEFINED: THETA_CAP)

   * - `Iota`
- 921
- $( UNDEFINED: IOTA_CAP)

   * - `Kappa`
- 922
- $( UNDEFINED: KAPPA_CAP)

   * - `Lambda`
- 923
- $( UNDEFINED: LAMBDA_CAP)

   * - `Mu`
- 924
- $( UNDEFINED: MU_CAP)

   * - `Nu`
- 925
- $( UNDEFINED: NU_CAP)

   * - `Xi`
- 926
- $( UNDEFINED: XI_CAP)

   * - `Omicron`
- 927
- $( UNDEFINED: OMICRON_CAP)

   * - `Pi`
- 928
- $( UNDEFINED: PI_CAP)

   * - `Rho`
- 929
- $( UNDEFINED: RHO_CAP)

   * - `Sigma`
- 931
- $( UNDEFINED: SIGMA_CAP)

   * - `Tau`
- 932
- $( UNDEFINED: TAU_CAP)

   * - `Upsilon`
- 933
- $( UNDEFINED: UPSILON_CAP)

   * - `Phi`
- 934
- $( UNDEFINED: PHI_CAP)

   * - `Chi`
- 935
- $( UNDEFINED: CHI_CAP)

   * - `Psi`
- 936
- $( UNDEFINED: PSI_CAP)

   * - `Omega`
- 937
- $( UNDEFINED: OMEGA_CAP)

   * - `alpha`
- 945
- $( UNDEFINED: ALPHA)

   * - `beta`
- 946
- $( UNDEFINED: BETA)

   * - `gamma`
- 947
- &x03b3;

   * - `delta`
- 948
- $( UNDEFINED: DELTA)

   * - `epsilon`
- 949
- $( UNDEFINED: EPSILON)

   * - `zeta`
- 950
- $( UNDEFINED: ZETA)

   * - `eta`
- 951
- $( UNDEFINED: ETA)

   * - `theta`
- 952
- $( UNDEFINED: THETA)

   * - `iota`
- 953
- $( UNDEFINED: IOTA)

   * - `kappa`
- 954
- $( UNDEFINED: KAPPA)

   * - `lambda`
- 955
- $( UNDEFINED: LAMBDA)

   * - `mu`
- 956
- $( UNDEFINED: MU)

   * - `nu`
- 957
- $( UNDEFINED: NU)

   * - `xi`
- 958
- $( UNDEFINED: XI)

   * - `omicron`
- 959
- $( UNDEFINED: OMICRON)

   * - `pi`
- 960
- $( UNDEFINED: PI)

   * - `rho`
- 961
- $( UNDEFINED: RHO)

   * - `sigmaf`
- 962
- $( UNDEFINED: SIGMAF)

   * - `sigma`
- 963
- $( UNDEFINED: SIGMA)

   * - `tau`
- 964
- $( UNDEFINED: TAU)

   * - `upsilon`
- 965
- $( UNDEFINED: UPSILON)

   * - `phi`
- 966
- $( UNDEFINED: PHI)

   * - `chi`
- 967
- $( UNDEFINED: CHI)

   * - `psi`
- 968
- $( UNDEFINED: PSI)

   * - `omega`
- 969
- $( UNDEFINED: OMEGA)

   * - `thetasym`
- 977
- $( UNDEFINED: THETASYM)

   * - `upsih`
- 978
- $( UNDEFINED: UPSIH)

   * - `piv`
- 982
- $( UNDEFINED: PIV)

   * - `bull`
- 8226
- $( UNDEFINED: BULL)

   * - `hellip`
- 8230
- $( UNDEFINED: HELLIP)

   * - `prime`
- 8242
- $( UNDEFINED: PRIME)

   * - `Prime`
- 8243
- $( UNDEFINED: PRIME_CAP)

   * - `oline`
- 8254
- $( UNDEFINED: OLINE)

   * - `frasl`
- 8260
- $( UNDEFINED: FRASL)

   * - `weierp`
- 8472
- $( UNDEFINED: WEIERP)

   * - `image`
- 8465
- <img src="" alt="" />

   * - `real`
- 8476
- $( UNDEFINED: REAL)

   * - `trade`
- 8482
- $( UNDEFINED: TRADE)

   * - `alefsym`
- 8501
- $( UNDEFINED: ALEFSYM)

   * - `larr`
- 8592
- $( UNDEFINED: LARR)

   * - `uarr`
- 8593
- $( UNDEFINED: UARR)

   * - `rarr`
- 8594
- ->

   * - `darr`
- 8595
- $( UNDEFINED: DARR)

   * - `harr`
- 8596
- <->

   * - `crarr`
- 8629
- $( UNDEFINED: CRARR)

   * - `lArr`
- 8656
- $( UNDEFINED: LARR_CAP)

   * - `uArr`
- 8657
- $( UNDEFINED: UARR_CAP)

   * - `rArr`
- 8658
- $( UNDEFINED: RARR_CAP)

   * - `dArr`
- 8659
- $( UNDEFINED: DARR_CAP)

   * - `hArr`
- 8660
- $( UNDEFINED: HARR_CAP)

   * - `forall`
- 8704
- $( UNDEFINED: FORALL)

   * - `part`
- 8706
- $( UNDEFINED: PART)

   * - `exist`
- 8707
- $( UNDEFINED: EXIST)

   * - `empty`
- 8709
- $( UNDEFINED: EMPTY)

   * - `nabla`
- 8711
- $( UNDEFINED: NABLA)

   * - `isin`
- 8712
- $( UNDEFINED: ISIN)

   * - `notin`
- 8713
- $( UNDEFINED: NOTIN)

   * - `ni`
- 8715
- $( UNDEFINED: NI)

   * - `prod`
- 8719
- $( UNDEFINED: PROD)

   * - `sum`
- 8721
- $( UNDEFINED: SUM)

   * - `minus`
- 8722
- -

   * - `lowast`
- 8727
- $( UNDEFINED: LOWAST)

   * - `radic`
- 8730
- $( UNDEFINED: RADIC)

   * - `prop`
- 8733
- $( UNDEFINED: PROP)

   * - `infin`
- 8734
- infinity

   * - `ang`
- 8736
- $( UNDEFINED: ANG)

   * - `and`
- 8743
- $( UNDEFINED: AND)

   * - `or`
- 8744
- $( UNDEFINED: OR)

   * - `cap`
- 8745
- $( UNDEFINED: CAP)

   * - `cup`
- 8746
- $( UNDEFINED: CUP)

   * - `int`
- 8747
- $( UNDEFINED: INT)

   * - `there4`
- 8756
- $( UNDEFINED: THERE4)

   * - `sim`
- 8764
- $( UNDEFINED: SIM)

   * - `cong`
- 8773
- $( UNDEFINED: CONG)

   * - `asymp`
- 8776
- $( UNDEFINED: ASYMP)

   * - `ne`
- 8800
- $( UNDEFINED: NE)

   * - `equiv`
- 8801
- $( UNDEFINED: EQUIV)

   * - `le`
- 8804
- $( UNDEFINED: LE)

   * - `ge`
- 8805
- $( UNDEFINED: GE)

   * - `sub`
- 8834
- $( UNDEFINED: SUB)

   * - `sup`
- 8835
- $( UNDEFINED: SUP)

   * - `nsub`
- 8836
- $( UNDEFINED: NSUB)

   * - `sube`
- 8838
- $( UNDEFINED: SUBE)

   * - `supe`
- 8839
- $( UNDEFINED: SUPE)

   * - `oplus`
- 8853
- $( UNDEFINED: OPLUS)

   * - `otimes`
- 8855
- $( UNDEFINED: OTIMES)

   * - `perp`
- 8869
- $( UNDEFINED: PERP)

   * - `sdot`
- 8901
- $( UNDEFINED: SDOT)

   * - `lceil`
- 8968
- $( UNDEFINED: LCEIL)

   * - `rceil`
- 8969
- $( UNDEFINED: RCEIL)

   * - `lfloor`
- 8970
- $( UNDEFINED: LFLOOR)

   * - `rfloor`
- 8971
- $( UNDEFINED: RFLOOR)

   * - `loz`
- 9674
- $( UNDEFINED: LOZ)

   * - `spades`
- 9824
- $( UNDEFINED: SPADES)

   * - `clubs`
- 9827
- $( UNDEFINED: CLUBS)

   * - `hearts`
- 9829
- $( UNDEFINED: HEARTS)

   * - `diams`
- 9830
- $( UNDEFINED: DIAMS)

   * - `lang`
- 10216
- $( UNDEFINED: LANG)

   * - `rang`
- 10217
- $( UNDEFINED: RANG)

   
)
portability, Portability Guide, memory-safe-d, Memory Safety




Link_References:
	ACC = Associated C Compiler
+/
module entity.dd;