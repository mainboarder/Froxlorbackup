##
# This just shows how to decrypt and untar files
# replace $encryption with your path to the encryption file
##

openssl aes-256-cbc -d -kfile $encryption -in file.enc.tar.gz > file.tar.gz
tar xzfv file.tar.gz
