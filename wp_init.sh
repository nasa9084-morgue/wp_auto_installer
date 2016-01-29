#!/usr/bin/bash -eu

password="SET YOUR PASSWORD"
upass=""
verbose_flg=0

while getopts u:D:p:v OPT
do
    case $OPT in
        u) uname=$OPTARG
           ;;
        D) wpdir=$OPTARG
           ;;
        p) upass=$OPTARG
           ;;
        v) verbose_flg=1
           ;;
    esac
done

if [ $verbose_flg -eq 1 ]
then
    echo "username=${uname-}"
fi
uname=${uname-""}
if [ -z "$uname" ]
then
    if [ $verbose_flg -eq 1 ]
    then
        echo "User name is not defined."
    fi

    exit
fi

wget "https://ja.wordpress.org/latest-ja.zip"
if [ $verbose_flg -eq 1 ]
then
    unzip -v "latest-ja.zip"
else
    unzip "latest-ja.zip"
fi
wpdir=${wpdir-"wordpress"}
if [ ${wpdir} != "wordpress" ]
then
    mv ./wordpress ./${wpdir}
fi

if [ $verbose_flg -eq 1 ]
then
    echo "install directory was set."
    echo "create database."
fi
mysql -u root --password=$password -e "create database if not exists wp_${uname};"

if [ $verbose_flg -eq 1 ]
then
    echo "database is created."
    echo "configure...."
fi

cat <<EOF > ./${wpdir-"wordpress"}/wp-config.php
<?php
/** WordPress のためのデータベース名 */
define('DB_NAME', 'wp_${uname}');

/** MySQL データベースのユーザー名 */
define('DB_USER', '${uname}');

/** MySQL データベースのパスワード */
define('DB_PASSWORD', '${upass}');

/** MySQL のホスト名 */
define('DB_HOST', 'localhost');

/** データベースのテーブルを作成する際のデータベースの文字セット */
define('DB_CHARSET', 'utf8');

/** データベースの照合順序 (ほとんどの場合変更する必要はありません) */
define('DB_COLLATE', '');

/**#@+ * 認証用ユニークキー */
EOF

curl -L "https://api.wordpress.org/secret-key/1.1/salt/" >> wp-config.php

cat <<EOF >> ./${wpdir-"wordpress"}/wp-config.php
/**#@-*/

/**
 * WordPress データベーステーブルの接頭辞
 */
$table_prefix  = 'wp_';

/**
 * 開発者へ: WordPress デバッグモード
 *
 * この値を true にすると、開発中に注意 (notice) を表示します。
 * テーマおよびプラグインの開発者には、その開発環境においてこの WP_DEBUG を使用することを強く推奨します。
 *
 * その他のデバッグに利用できる定数については Codex をご覧ください。
 *
 * @link http://wpdocs.osdn.jp/WordPress%E3%81%A7%E3%81%AE%E3%83%87%E3%83%90%E3%83%83%E3%82%B0
 */
define('WP_DEBUG', false);

/* 編集が必要なのはここまでです ! WordPress でブログをお楽しみください。 */

/** Absolute path to the WordPress directory. */
if ( !defined('ABSPATH') )
	define('ABSPATH', dirname(__FILE__) . '/');

/** Sets up WordPress vars and included files. */
require_once(ABSPATH . 'wp-settings.php');
EOF

if [ $verbose_flg -eq 1 ]
then
    echo "done."
fi

if [ $verbose_flg -eq 1 ]
then
    echo "Wordpress installation is done."
fi
