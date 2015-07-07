_hash_obj() {
    file="$1"
    echo $(shasum "${file}" | awk '{print $1}')
}

init() {
    path="$1";
    if [ ! -d "${path}" ]; then
        echo "Path '${path}' does not exist"; return;
    fi
    cd "${path}";
    export DVCSH="$(pwd)/.dvcsh"
    mkdir -p "${DVCSH}/objects";
    echo "Initialized empty repository in ${DVCSH}/";
}

add() {
    file="$1";
    sha=$(_hash_obj "${file}");
    cp -p "$1" "${DVCSH}/objects/${sha}"

    if [ -f "${DVCSH}/index" ]; then
        egrep -v "\t${file}\$" "${DVCSH}/index" >> "${DVCSH}/index.tmp"
    fi
    printf "${sha}\t${file}\n" >> "${DVCSH}/index.tmp"
    mv "${DVCSH}/index.tmp" "${DVCSH}/index"
}

commit() {
    sha=$(_hash_obj "${DVCSH}/index");
    if [ -f "${DVCSH}/objects/${sha}" ]; then
        echo "nothing to commit"; return;
    fi
    cp -p "${DVCSH}/index" "${DVCSH}/objects/${sha}"

    echo "index: ${sha}" > "${DVCSH}/commit.last";
    echo "date: $(date)" >> "${DVCSH}/commit.last";

    if [ -f "${DVCSH}/HEAD" ]; then
        echo "parent: $(cat "${DVCSH}/HEAD")" >> "${DVCSH}/commit.last";
    fi

    echo "comment: ${1:-(no comment)}" >> "${DVCSH}/commit.last"

    sha=$(_hash_obj "${DVCSH}/commit.last");
    cp -p "${DVCSH}/commit.last" "${DVCSH}/objects/${sha}"

    echo "${sha}" > "${DVCSH}/HEAD";
}

log() {
    if [ ! -f "${DVCSH}/HEAD" ]; then echo "No commits yet"; return; fi
    sha=$(cat "${DVCSH}/HEAD");
    path="${DVCSH}/objects/${sha}"

    while [ ! -z "${sha}" ]; do
        echo "commit: ${sha}"
        printf "  "; egrep '^date: ' ${path}
        printf "  "; egrep '^comment: ' ${path}
        echo

        sha=$(egrep -h '^parent: ' "${path}" | awk '{print $2}')
        path="${DVCSH}/objects/${sha}"
    done
}
