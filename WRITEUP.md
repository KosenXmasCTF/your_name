# Writeup
彼が残した設定ファイルから，フラグは `https://hidden.your_name.xm4s.net/flag.txt` に隠されたことが推測できます．
しかし，以下のようにアクセスしてもアクセスできません．

```console
$ curl https://hidden.your_name.xm4s.net/flag.txt
curl: (6) Could not resolve host: hidden.your_name.xm4s.net
```

隠されたサーバは， DNS で名前解決を行うことができないようです．
そこで，設定ファイルを再度見てみると，どうやら frontend サーバと hidden サーバは Docker ネットワークで接続されているようです．
つまり，インターネットから見て 2 つのサーバは同じ IP アドレスでホストされているといえます．

このホスト方法はバーチャルホストという名前でよく知られています．
1 つしか IP アドレスを持っていなくても，ドメイン名によって複数のサーバであるかのように振る舞うことができます．
通常の HTTP におけるバーチャルホストでは， `Host` ヘッダでドメイン名を指定してアクセスします．
そこで，以下のようにアクセスを試みます．

```console
$ curl https://your_name.xm4s.net/flag.txt -H 'Host: hidden.your-name.xm4s.net'
Nothing here!
```

しかし，この方法は彼によって対策されているようです．
では，このサーバはどのようにしてバーチャルホストをつくっているのでしょうか．

すべての接続が HTTP ではなく TLS の上で動作する HTTPS で行われていることに注目します．
TLS での接続は暗号化されているため，直接通信するサーバでないと中身の `Host` ヘッダを読むことはできません．
その代わりに， TLS の機能として SNI (Server Name Indication) が存在します．
これにより， TLS パケットにドメイン名をつけて送信することで通信先のサーバを判断することができます．
OpenSSL クライアントを使って SNI を明示的に指定してリクエストしてみます．

```console
$ echo -e "GET /flag.txt HTTP/1.1\nHost: hidden.your-name.xm4s.net\n\n" | openssl s_client -connect localhost:443 -servername hidden.your-name.xm4s.net -quiet -crlf
# 省略
xm4s{...}
```

これでフラグを入手できました．

別解法として，ローカルで `hidden.your-name.xm4s.net` を名前解決させることで同様の結果が得られます．
`/etc/hosts` 等の編集でも可能ですが， cURL のオプションを用いることでより簡単に行えます．

```console
$ curl -k https://hidden.your-name.xm4s.net/flag.txt --resolve "hidden.your-name.xm4s.net:443:$(dig +short your-name.xm4s.net)"
```
