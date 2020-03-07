## Qtum Formula
[/qtumproject/qtum](https://github.com/qtumproject/qtum)

## Qtum API
[Qtum RPC API](https://docs.qtum.site/en/Qtum-RPC-API/)

## Qtum Explorer
[qtum info](https://qtum.info/)  
[qtumblockexplorer](https://qtumblockexplorer.com/)

## Build method
docker build --build-arg PARENT_QTUM_VERSION=0.19.0 --build-arg CHILD_QTUM_VERSION=0.19.0.1 --build-arg GOSU_VERSION=1.11 -t qtum-core:v0.19.0.1 -f Dockerfile .
