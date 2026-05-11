#!/bin/bash

# Commands
#   list_documents
#   list_folder
#   download_pdf
#   download_rmdoc
#   download_log
#   download_thumbnail_latest_page
#   search_keyword
#   upload_file

RMK_GUID_FOLDER=ed57e608-d307-47dd-a033-0357731c0859
RMK_GUID_FILE=b3dd469a-93d6-4753-a7cf-474238a6cef5
RMK_KEYWORD=thesis

echo "$RMK_GUID_FOLDER: $RMK_GUID_FILE ($RMK_KEYWORD)"

case "$1" in

list_documents)
    # ---------------
    # GET http://10.11.99.1/documents/
    #
    # Get the document and folders list for the root folder. This will also respond to POST requests.
    #
    # Example:
    #
    # curl \
    #   --silent \
    #   http://10.11.99.1/documents/ \
    # | jq -r 'map({(.ID): {VissibleName,Type}}) | add'
    mkdir -p data
    curl http://10.11.99.1/documents/ >data/documents.json
    cat data/documents.json | jq
    ;;

list_folder)
    # ---------------
    # GET http://10.11.99.1/documents/{guid}
    #
    # Get the documents and folders list for a specific folder. This will also respond to POST requests.
    #
    # Example:
    #
    # guid=fd2c4b2c-3849-46c3-bf2d-9c80994cc985
    # curl \
    #   --silent \
    #   "http://10.11.99.1/documents/$guid" \
    # | jq -r 'map({(.ID): {VissibleName,Type}}) | add'
    mkdir -p data/folders
    curl http://10.11.99.1/documents/$RMK_GUID_FOLDER >data/folders/$RMK_GUID_FOLDER.json
    cat data/folders/$RMK_GUID_FOLDER.json | jq
    ;;

download_pdf)
    # ---------------
    # GET http://10.11.99.1/download/{guid}/pdf
    #
    # Download the PDF for a specific document.
    #
    # Example:
    #
    # guid=fd2c4b2c-3849-46c3-bf2d-9c80994cc985
    # curl \
    #   -I "http://10.11.99.1/download/$guid/pdf"
    mkdir -p data/files
    curl http://10.11.99.1/download/$RMK_GUID_FILE/pdf >data/files/$RMK_GUID_FILE.pdf
    zathura data/files/$RMK_GUID_FILE.pdf &
    ;;

download_rmdoc)
    # ---------------
    # GET http://10.11.99.1/download/{guid}/rmdoc
    #
    # Download the raw notebook archive for a specific document. This was added in v3.9.
    #
    # Example:
    #
    # guid=fd2c4b2c-3849-46c3-bf2d-9c80994cc985
    # curl \
    #   -I "http://10.11.99.1/download/$guid/rmdoc"
    mkdir -p data/files
    curl http://10.11.99.1/download/$RMK_GUID_FILE/rmdoc >data/files/$RMK_GUID_FILE.rmdoc
    ;;

download_log)
    # ---------------
    # GET http://10.11.99.1/log.txt
    #
    # Download the xochitl log file found at /home/root/log.txt.
    #
    # Example:
    #
    # curl \
    #   --silent \
    #   --remote-name \
    #   --remote-header-name \
    #   'http://10.11.99.1/log.txt'
    mkdir -p data
    curl \
        --silent \
        --remote-name \
        --remote-header-name \
        'http://10.11.99.1/log.txt' >data/log.txt
    cat data/log.txt
    ;;

download_thumbnail_latest_page)
    # ---------------
    # GET http://10.11.99.1/thumbnail/{guid}
    #
    # Download the thumbnail for a specific document (latest page opened).
    #
    # Example:
    #
    # guid=fd2c4b2c-3849-46c3-bf2d-9c80994cc985
    # curl \
    #   -I "http://10.11.99.1/thumbnail/$guid"
    mkdir -p data/files
    curl http://10.11.99.1/thumbnail/$RMK_GUID_FILE >data/files/"$RMK_GUID_FILE"_thumbnail.png
    feh data/files/"$RMK_GUID_FILE"_thumbnail.png &
    ;;

search_keyword)
    # ---------------
    # POST 'http://10.11.99.1/search/{keyword}'
    #
    # Search for documents matching a specific keyword. This endpoint is currently under development, and may not work as expected.
    #
    # Example:
    #
    # keyword="planning"
    # curl \
    #   -X POST \
    #   "http://10.11.99.1/search/$keyword" \
    # | jq -r 'map({(.ID): {VissibleName,Type}}) | add'
    # BUG: Does not work
    curl \
        -X POST \
        "http://10.11.99.1/search/$RMK_KEYWORD" |
        jq
    ;;

upload_file)
    # ---------------
    # POST http://10.11.99.1/upload
    #
    # Upload a document to the last folder that was listed.
    #
    # Example:
    #
    # file=Get_started_with_reMarkable.pdf
    # curl \
    #   'http://10.11.99.1/upload' \
    #   -H 'Origin: http://10.11.99.1' \
    #   -H 'Accept: */*' \
    #   -H 'Referer: http://10.11.99.1/' \
    #   -H 'Connection: keep-alive' \
    #   -F "file=@$file;filename=$(basename "$file");type=application/pdf"
    #   TODO:
    # First 'navigate to folder'
    curl http://10.11.99.1/documents/$RMK_GUID_FOLDER
    # Then upload
    curl \
        'http://10.11.99.1/upload' \
        -H 'Origin: http://10.11.99.1' \
        -H 'Accept: */*' \
        -H 'Referer: http://10.11.99.1/' \
        -H 'Connection: keep-alive' \
        -F "file=@$RMK_GUID_FILE;filename=$(basename "$RMK_GUID_FILE");type=application/pdf"
    ;;

*)
    echo "Commands: "
    echo "  list_documents"
    echo "  list_folder"
    echo "  download_pdf"
    echo "  download_rmdoc"
    echo "  download_log"
    echo "  download_thumbnail_latest_page"
    echo "  search_keyword"
    echo "  upload_file"
    ;;
esac
