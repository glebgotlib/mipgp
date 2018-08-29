#!/bin/sh

make clean
rm libgpg.a

make all

ar cru libgpg.a build-packet.o compress.o compress-bz2.o free-packet.o getkey.o keydb.o keyring.o seskey.o kbnode.o mainproc.o armor.o mdfilter.o textfilter.o progress.o misc.o openfile.o keyid.o parse-packet.o status.o plaintext.o sig-check.o keylist.o signal.o cardglue.o tlv.o card-util.o app-openpgp.o iso7816.o apdu.o ccid-driver.o pkclist.o skclist.o pubkey-enc.o passphrase.o seckey-cert.o encr-data.o cipher.o encode.o sign.o verify.o revoke.o decrypt.o keyedit.o dearmor.o import.o export.o trustdb.o tdbdump.o tdbio.o delkey.o keygen.o pipemode.o helptext.o keyserver.o photoid.o exec.o
