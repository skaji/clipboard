# clipboard

Share clipboad with several machines.

## usage

### prepare

In .bashrc:

    alias pbcopy='perl -e '\''$/ = undef; $d = <>; exec "curl", "http://user:pass\@shoichi.me:5555/pbcopy", "--data-binary", $d'\'''
    alias pbpaste='curl '\''http://user:pass@shoichi.me:5555/pbpaste'\'''

(change user and pass appropriately)

### then..

    user@machineA $ echo hello from mahineA | pbcopy

    user@machineB $ pbpaste
    hello from machineA

## AUTHOR

Shiochi Kaji
