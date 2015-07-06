_hash_obj() {
    file="$1"
    echo $(shasum "${file}" | awk '{print $1}')
}

init() {
    path="$1";
    if [ ! -d "${path}" ]; then echo "Path '${path}' does not exist"; return; fi
    cd ${path};
    repo=`pwd`;
    export DVCSH="${repo}/.dvcsh"
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
    cp -p "${DVCSH}/index" "${DVCSH}/objects/${sha}"
    echo "index: ${sha}" > "${DVCSH}/commit.last";

    date=$(date)
    echo "date: ${date}" >> "${DVCSH}/commit.last";
    if [ -f "${DVCSH}/HEAD" ]; then
        parent=$(cat "${DVCSH}/HEAD");
        echo "parent: ${parent}" >> "${DVCSH}/commit.last";
    fi

    comment="${1:-(no comment)}"
    echo "comment: ${comment}" >> "${DVCSH}/commit.last"

    file="${DVCSH}/commit.last"
    sha=$(_hash_obj "${file}");
    cp -p "${file}" "${DVCSH}/objects/${sha}"

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
