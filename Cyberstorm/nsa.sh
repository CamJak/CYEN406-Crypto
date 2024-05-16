#!/bin/sh
# This script was generated using Makeself 2.5.0
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="3147212250"
MD5="1cb4f9e535c19a272bf4f935f47fd1ca"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
SIGNATURE=""
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="NSA CLI"
script="./nsa-plain"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=""
targetdir="Obfuscate"
filesizes="3764"
totalsize="3764"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="714"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  PAGER=${PAGER:=more}
  if test x"$licensetxt" != x; then
    PAGER_PATH=`exec <&- 2>&-; which $PAGER || command -v $PAGER || type $PAGER`
    if test -x "$PAGER_PATH"; then
      echo "$licensetxt" | $PAGER
    else
      echo "$licensetxt"
    fi
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -k "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    # Test for ibs, obs and conv feature
    if dd if=/dev/zero of=/dev/null count=1 ibs=512 obs=512 conv=sync 2> /dev/null; then
        dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
        { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
          test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
    else
        dd if="$1" bs=$2 skip=1 2> /dev/null
    fi
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd "$@"
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 count=1 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
Makeself version 2.5.0
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive
  $0 --verify-sig key Verify signature agains a provided key id

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet               Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script (implies --noexec-cleanup)
  --noexec-cleanup      Do not run embedded cleanup script
  --keep                Do not erase target directory after running
                        the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the target folder to the current user
  --chown               Give the target folder to the current user recursively
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --ssl-pass-src src    Use the given src as the source of password to decrypt the data
                        using OpenSSL. See "PASS PHRASE ARGUMENTS" in man openssl.
                        Default is to prompt the user to enter decryption password
                        on the current terminal.
  --cleanup-args args   Arguments to the cleanup script. Wrap in quotes to provide
                        multiple arguments.
  --                    Following arguments will be passed to the embedded script${helpheader}
EOH
}

MS_Verify_Sig()
{
    GPG_PATH=`exec <&- 2>&-; which gpg || command -v gpg || type gpg`
    MKTEMP_PATH=`exec <&- 2>&-; which mktemp || command -v mktemp || type mktemp`
    test -x "$GPG_PATH" || GPG_PATH=`exec <&- 2>&-; which gpg || command -v gpg || type gpg`
    test -x "$MKTEMP_PATH" || MKTEMP_PATH=`exec <&- 2>&-; which mktemp || command -v mktemp || type mktemp`
	offset=`head -n "$skip" "$1" | wc -c | sed "s/ //g"`
    temp_sig=`mktemp -t XXXXX`
    echo $SIGNATURE | base64 --decode > "$temp_sig"
    gpg_output=`MS_dd "$1" $offset $totalsize | LC_ALL=C "$GPG_PATH" --verify "$temp_sig" - 2>&1`
    gpg_res=$?
    rm -f "$temp_sig"
    if test $gpg_res -eq 0 && test `echo $gpg_output | grep -c Good` -eq 1; then
        if test `echo $gpg_output | grep -c $sig_key` -eq 1; then
            test x"$quiet" = xn && echo "GPG signature is good" >&2
        else
            echo "GPG Signature key does not match" >&2
            exit 2
        fi
    else
        test x"$quiet" = xn && echo "GPG signature failed to verify" >&2
        exit 2
    fi
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n "$skip" "$1" | wc -c | sed "s/ //g"`
    fsize=`cat "$1" | wc -c | sed "s/ //g"`
    if test $totalsize -ne `expr $fsize - $offset`; then
        echo " Unexpected archive size." >&2
        exit 2
    fi
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" != x"$crc"; then
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2
			elif test x"$quiet" = xn; then
				MS_Printf " CRC checksums are OK." >&2
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

MS_Decompress()
{
    if test x"$decrypt_cmd" != x""; then
        { eval "$decrypt_cmd" || echo " ... Decryption failed." >&2; } | eval "gzip -cd"
    else
        eval "gzip -cd"
    fi
    
    if test $? -ne 0; then
        echo " ... Decompression failed." >&2
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." >&2; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. >&2; kill -15 $$; }
    fi
}

MS_exec_cleanup() {
    if test x"$cleanup" = xy && test x"$cleanup_script" != x""; then
        cleanup=n
        cd "$tmpdir"
        eval "\"$cleanup_script\" $scriptargs $cleanupargs"
    fi
}

MS_cleanup()
{
    echo 'Signal caught, cleaning up' >&2
    MS_exec_cleanup
    cd "$TMPROOT"
    rm -rf "$tmpdir"
    eval $finish; exit 15
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=
sig_key=

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 20 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Thu May 16 14:52:47 CDT 2024
	echo Built with Makeself version 2.5.0
	echo Build command was: "./makeself.sh \\
    \"./Obfuscate/\" \\
    \"nsa.sh\" \\
    \"NSA CLI\" \\
    \"./nsa-plain\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
    echo CLEANUPSCRIPT=\"$cleanup_script\"
	echo archdirname=\"Obfuscate\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
    echo totalsize=\"$totalsize\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5sum\"
	echo SHAsum=\"$SHAsum\"
	echo SKIP=\"$skip\"
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n "$skip" "$0" | wc -c | sed "s/ //g"`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n "$skip" "$0" | wc -c | sed "s/ //g"`
	arg1="$2"
    shift 2 || { MS_Help; exit 1; }
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --verify-sig)
    sig_key="$2"
    shift 2 || { MS_Help; exit 1; }
    MS_Verify_Sig "$0"
    ;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
    cleanup_script=""
	shift
	;;
    --noexec-cleanup)
    cleanup_script=""
    shift
    ;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    shift 2 || { MS_Help; exit 1; }
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --chown)
        ownership=y
        shift
        ;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--ssl-pass-src)
	if test x"n" != x"openssl"; then
	    echo "Invalid option --ssl-pass-src: $0 was not encrypted with OpenSSL!" >&2
	    exit 1
	fi
	decrypt_cmd="$decrypt_cmd -pass $2"
    shift 2 || { MS_Help; exit 1; }
	;;
    --cleanup-args)
    cleanupargs="$2"
    shift 2 || { MS_Help; exit 1; }
    ;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    export USER_PWD="$tmpdir"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if test -t 1; then  # Do we have a terminal on stdout?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0 >&2
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -e "$0 --xwin $initargs"
                else
                    exec $XTERM -e "./$0 --xwin $initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n "$skip" "$0" | wc -c | sed "s/ //g"`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 20 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = x"openssl"; then
	    echo "Decrypting and uncompressing $label..."
	else
        MS_Printf "Uncompressing $label"
	fi
fi
res=3
if test x"$keep" = xn; then
    trap MS_cleanup 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 20; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (20 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | MS_Decompress | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        MS_CLEANUP="$cleanup"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi

MS_exec_cleanup

if test x"$keep" = xn; then
    cd "$TMPROOT"
    rm -rf "$tmpdir"
fi
eval $finish; exit $res
‹ dFfíZmo7Î×È`¶Q¯l½95Pm5	.~A¤\Z$AíRÒÖ+®º/V}iÿÁ}ì/¼_r3CrÉ•ä4½»æp‡%ÛZ’ÃáÌ3Ï¹jÈ”{Ëˆ‡òÎŸÕ¡=êvï6u›ö7µV§İ=ºÓìµà³Õ†çÍVëèÑvxç´<Íxªø|ñ#ÿ77	­øı?Ò>8˜„ò`ÂÓùı{÷ï=dÏEÆşÊ“O"‘ªGgÃáÉˆ¾¿z3²‹ÁøÅı{×<ÊÅ4ŒD¿vpÍ“ƒ€gü xØ€µû÷.£ÑÅ‹×ƒÑ°_åK‘œà‘ğóD\ğ4]ÎŠÇ‡ÍšZ)œ²•`A,w26ç×‚q†ÒöYˆŸS6B²Œ/@ˆØ*Ìæì›Şîı{0ï{À¼)«ÕjìÃ–Í…¼Aş<fµâ\I.Ka´Ò† 
XkJÆ¥X5Øğç0å¬Ñh€¢w|bM¥q3“U˜
–R€M“xQˆÅ‘Ó8Yğ¬ÇNß_^œ¿<<õër|>¼2FãÁó¡§~½9UŸGŞê|3x¯‡§ƒ—g/Ï_ÆãáéÅxtÿˆR¡¶I«_
é÷ë»O]kìæô	:Èõb(û…ÅK!Ó4b\¤^«{äùŸyó8ó–à(†?zuëOx<¹
¦-”úò»QÇÛQğœD¢SöôéSã4œİz¿şQywøáWèq-aûšnÂöµ¨oía›Z³ÙõX+Ú.õlÕ8ÂÓP9|ñ”1˜âñ™fuZ… ¶»M4ŠRíòd8:î[Ôı¨(…×áÅÂ
‹§–@\‡¾`©ÿĞœÜĞÃ³Ñ ÁŞ
%!Š}AÌÏ%7Kü°äI%ƒVNÃ¢YM£¾ÔOÂeòŒ…)ËSÅ0…¤ÑB^ƒKĞçÆè?s8RöYšO¡š:7AÈ1É‚í†Òò@­-~Î g¨(„,¿æa„<f+<a<Šè/ÀO[]Œ Êúsèr&ö(ï>d/¶.Z[ÈìwqÙ…\ó¸f28½¾î×&mqÄƒNWt;ƒÎ×İÃ‰Ïùa[4§[G“£)MA$fúü¨şÜ­!æ›–KÁ“m7{ÄÜ‡ŠrÜ`"f<	€5´CÈºØ¡æa|˜Äq†´Âjà`Ün*v-a@ç™åí6=gŸeÉx5¾ÂÑ`?r0ˆO•c}ÀG’Ëb	Xà<OĞhŸ¥Ká‡<
Ó,U•<Iâ@!ˆWRíf§iˆî±²•#¬÷ı¹ğ¯ØÈüƒP†Y#8 `*€øI,3>Iqé±Õ¥¶i4G~œGÚPŠ4ÓŒLÔKäª'6Ø6<eaRr´öü¦¹Ÿå ”ØÌ¦5Ÿo‡£Ñåéèy¿vËYÂ³<RûTi`+â?/j"¸WÂ ºË\`Mğhj¡L$Ò`Iì%‘6¢»ŞK…Áá÷c%Âpgìzò~¶ng¯
¾øDä/`‹ùíÇlÆÑ#¾/ÒÔ¨:ƒ (ƒ.İG¿JÜRHÄµH€!VCxî¢F¯”‰d]lJ: ×V§¡~¼XF‚hÌpŸ$ŠA›,œ*Îœ ”ØBdó˜¶È³ŒP‰‚d‰d Í=ee¾Ó2Cm@%°Dz\¦+Ø–‚á˜Ü¹¤¦×İi°]tÊ*j›	bÀf{Åb™‘Eµ{šáÆÎ*)«¡Êsˆ%}¹ms;›‘³Mh±ıc`ëe‡ä»{ÜõË>[ğ+°td57¶¹²'‰ğ!·wÓ½5ƒ;¼zó—‘Â#Í¢ZCU†¤„Ü‚É}4”¼B]ÔÚ"1Èöôº•GdôVÃ^‰›tÉ}Q›»¯ŒATïS5S¬0ÑÖp@L|	"0wiJ²’)v'@S%®H[>²e«D­Ë`È@ˆ¸M½Y
k R,C_ğàšËL\ÙŒG¬ƒ(ô‚f÷Ï¶0â–ØIó°o…ÏÁ¬á.p«2_L –ğ¬È±)Ğ#Ô¤Xô‡Ù ˆ#Z€28ÛÀ)Kç&Pa >ü)ı+åËr7¾İ¶İbùZT‡í‚€Ûlœü»Æ †ˆbÄ(ãH«i¶¶«}íl˜ŒÜ.ÈEN?ƒ)CğÊ[Íº¸ß£ÔuW“Ohi˜GˆY“bÊ®¥-GâíÙáÓÄì°¥#ĞÄ¨Ş÷AYº.gwËì²]Ra	E3JQ Q%î·/_ŞÛ%ŒÏy³(jkO³H•©è´¾®ím’n³Ë[âë££v»3vÛ\mÿQ·İš<>švZâñ‘ÿø¨Õi¯qñ‘ËÅ£‰¶`’™É„Ÿ$*¢ÍV6¡V†ºÑ©8›oa'V¤&%´Ö´yQ:Oœ0Eş<-¹\?AÄqWkÇeœ¨£È‡Gí\ª¡VÅ}ªT%¸ÂÃtûÎ®±JÁeI¹)xB$Èª¨¹fu¨ÇšÁrŠ'R?¬e81L¹" Ü¥H(k¯ÍUúŒp@
Ï"(4=N®(JU~Xğ¤,”î¤	Òà
„ŠDWàSEañ/Bé…PƒbÍr–Òn?p'F}-²ˆ…JTÍOC£`ÓEˆ•[İØÆÕL¾(£‰¶­_›ÒG£LÜ;ß0EQ‰Û	t ƒƒªMÃVG§Œr‚÷OÓ¶Õëèø ’QÒœÊÓiT°F».[€ÉÑ;È¯·0ÚH*­RßÙH!gTs*Ê”ËKµ·S­l
P…|¨*ìvàÏIWqæÀû °F!›æˆ²ö2âRR&MšB/ëª0—ä+sOq¥Nd°¬^‰'áµÂ¥>˜¥S)À£Ã„ÖL‹##JÕ+è>tÖe‚~RêJ´4MBˆŸ½)ÄĞC$è!yne~zêœx?@k8Åµ³,Şƒ%tÜä÷Ã×ìz­ÃVgÁÛ[îˆäºİIÍµŒë6´Ç&\\y“–÷iSâ}îF‰|¦Õ4Õ5Ò
/L†£òdu{`8ø¤PÅŸ!!»ç;œiÎğ®&ÈHºh]wŞšë>uF0ìcXÉ¹AùcçtS‚èÆÜıñ9¾p°@=±‡<æ‡XÈÙƒ÷ò½ô<¯ßï@¹	VLÄ~qB¶¯»÷˜Ø;ÃqVÍÄºH¹oo‹ €AŠ•Ò»éF[_*zâ'Ö²—ÙwUßæ%<tn½Õt«Xƒ÷šænó»\gÓ½?r.§9ÔB{ì#¤)¨ƒŞË·"òcU”êëIvüê%ç…0E—újˆbr™Ä3¨øv‰ø)Ç“ùM¿¯xJ¯Š[åÁùkeDáÑšsŒgD:HHİï1™röTw}ƒcõ°Ş{‰{ê±“0€Ş¤Êíƒs‰õØ9^ƒëÃ®TĞ*«£)ÒjC½œ	lBM¨6bÀYö %¸Hó ¼\ì °‡¾	QÉóÉ[Q]™ÉãêZ™Må™_Ém°®ë¶‡x€Êğº•
¯¸ß¤ğoëéB-¤Ì\²q2ÀYÆêöVİE˜A…¥=‰y(ÆÅH[y £‚^§j(‚¾hÙ5ÃúØ|Rêp›*ïåEiòZ„÷ô²ø4DèÔwSˆ›¦+|ï	bT}¿X=ì±úGö®zÍ¿jYA,…İ€B¾²¸6
¦k¨Å§Ùö=	ehz¶}sg®};ô5Óš%"ËiusµÚ§—Eí‚¢56¡Ï4S–9€
Ctn^	uã§B[‰%v~Òê;¡»½4V¥¢–_ÜqkJÖtí²òîÍÜS{2¯™ĞF—¯‡£‹ó³Ñ°dÍâ)ë³ÚMÍµãî®5÷W_íí©g¥woı”fª§ä}½A8YgkFIÄ’b‘[Kşp%:`r^ï¨RïôÖ”À+ B-]K±¯È§ı.ÿ¼ğÿı4üK«uûq3Å–ÉÄâõ¿ı½o›§Û{ÉØ8ÎğvÌE^ïöq!¦”,!»§uàJ­Û²^=xA+©êÌ²’Ë8êâv,õÊ°ÃÍı¶us&'¨Ìñ_Å…|>şÔ²k=Á”¶^ò"3&f­õ½®Õ`´,l)ÉŠÏ:r+QkÕàœo0TV/ø"œŞ§dê˜\œt¨4 •ª=æ’äèÍ·§/K4©Ÿ¼:ÇCù*ÀÚ0öØÎ»^¾„óPïÃşÅ+ú{ÏI$Î‹	]Á»ÕêîB5dâº{*±rÉ'öºN»YÕÄw7üqö,Ÿ¾ê—¢E;Œ¡O&†®;ÇÍÂÿ’Ôrfé×7îŠqÎ7O¥R*w<Jë£ö'Ño.ˆP·ºµfŞMœ{VúóÏ&vƒ/Ş¦šeÎLUìl†Qƒîå‰lÚ9±Oóú­¸âÄyã	“nË@ü5ìÏç·]Şlºu«	
¿m÷ægcÁ–lÚÓŸe¨Ïã³¥Ô·KÖ|ƒ÷ô–ÂL%•ŠŠã¡ºûÂ£L2SçüÖÁÔ=H*H<h:şWßšiªoÌÜ­áÉL÷ïšƒ'} ë1è5M·>à¸İªğÑlTB9Ğ)¢¢æÚ2Ö.×<
6Hf9Ä28Ùá¥×2QÏ¢_‚¨{sA¶*¾1„ş¹Ößù"ßÃÜ÷ê›J'ƒñ ¿[sŠ¯”8½£yuıËYÖ-S· ;<;¾¤…tfñ$ØG|‚ßôªİöM3Î¼”GÙïÙ·–f±¾5¶ß€R[4KÖì›Ò7ïT­jU«ZÕªVµªU­jU«ZÕªVµªU­jU«ZÕªVµªU­jU«ZÕªVµªU­jU«ÚÿMû'Ñá\z P  