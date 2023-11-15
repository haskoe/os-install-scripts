#!/bin/bash -e

[[ ! -f $1 ]] && echo please specify adoc file && exit 1

DOC_PATH=$(dirname `realpath $1`)
DOC_FILE=$(basename -s .adoc $1)
ROOT_DOC_PATH=$DOC_PATH
DOCKER_DOC_FILE=$DOC_FILE
[[ ! -f ${DOC_PATH}/global-attrs.adoc ]] && ROOT_DOC_PATH=$DOC_PATH/..
[[ ! -f ${DOC_PATH}/global-attrs.adoc ]] && DOCKER_DOC_FILE=`echo $DOC_PATH | awk -F '/' '{print $NF}'`/$DOC_FILE

docker run --rm -v ${ROOT_DOC_PATH}:/documents/ asciidoctor/docker-asciidoctor asciidoctor $DOCKER_DOC_FILE.adoc -b docbook -a 'idprefix=' -a 'idseparator=-' -r asciidoctor-bibtex -r asciidoctor-diagram
pandoc ${DOC_PATH}/${DOC_FILE}.xml --toc --from docbook --to docx --output ${DOC_PATH}/${DOC_FILE}.docx 
