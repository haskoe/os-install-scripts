#!/bin/bash -e

[[ ! -f $1 ]] && echo please specify adoc file && exit 1

DOC_PATH=$(dirname `realpath $1`)
DOC_FILE=$(basename $1)

ROOT_DOC_PATH=$DOC_PATH
DOC_REL_PATH=.
[[ ! -f ${DOC_PATH}/global-attrs.adoc ]] && ROOT_DOC_PATH=$DOC_PATH/..
[[ ! -f ${DOC_PATH}/global-attrs.adoc ]] && DOC_REL_PATH=`echo $DOC_PATH | awk -F '/' '{print $NF}'`
DOCKER_DOC_FILE=${DOC_REL_PATH}/${DOC_FILE}

echo ":anslag: $(cat $(grep ^include..0 $1 | sed -e 's/^include..//g' | sed -e 's/..$//g') | tr -d '[:space:] ' | wc -c)">${DOC_PATH}/dyn-doc-attrs.adoc

docker run --rm -v ${ROOT_DOC_PATH}:/documents/ asciidoctor/docker-asciidoctor asciidoctor-pdf ${DOCKER_DOC_FILE} -r asciidoctor-bibtex -r asciidoctor-diagram
