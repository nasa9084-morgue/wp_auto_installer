#!/usr/bin/bash

password="SET YOUR PASSWORD"
upass=""

while getopts u:D:p: OPT
do
    case $OPT in
        u) uname=$OPTARG
           ;;
        D) wpdir=$OPTARG
           ;;
        p) upass=$OPTARG
    esac
done

if [ -n "${uname-}" ]
then
    return 1
fi

wget "https://ja.wordpress.org/latest-ja.zip"
unzip "latest-ja.zip"
wpdir=${wpdir-"wordpress"}
if [ ${wpdir} != "wordpress" ]
then
    mv ./wordpress ./${wpdir}
fi
mysql -u root -p $password -e "create database if not exists wp_${uname};"
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
