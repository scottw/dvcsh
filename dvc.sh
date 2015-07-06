_hash_obj() {
    file="$1"
    echo $(shasum "${file}" | awk '{print $1}')
}

init() {
    path="$1";
    if [ ! -d "${path}" ]; then echo "Path '${path}' does not exist"; return; fi
    mkdir -p "${path}/.repo/objects";
    cd ${path};
    export REPO=`pwd`;
    echo "Initialized empty repository in ${REPO}/.repo/";
}

add() {
    file="$1";
    sha=$(_hash_obj "${file}");
    cp -p "$1" "${REPO}/.repo/objects/${sha}"

    if [ -f "${REPO}/.repo/index" ]; then
        egrep -v "\t${file}\$" "${REPO}/.repo/index" >> "${REPO}/.repo/index.tmp"
    fi
    printf "${sha}\t${file}\n" >> "${REPO}/.repo/index.tmp"
    mv "${REPO}/.repo/index.tmp" "${REPO}/.repo/index"
}

commit() {
    sha=$(_hash_obj "${REPO}/.repo/index");
    cp -p "${REPO}/.repo/index" "${REPO}/.repo/objects/${sha}"
    echo "index: ${sha}" > "${REPO}/.repo/commit.last";

    date=$(date)
    echo "date: ${date}" >> "${REPO}/.repo/commit.last";
    if [ -f "${REPO}/.repo/HEAD" ]; then
        parent=$(cat "${REPO}/.repo/HEAD");
        echo "parent: ${parent}" >> "${REPO}/.repo/commit.last";
    fi

    comment="${1:-(no comment)}"
    echo "comment: ${comment}" >> "${REPO}/.repo/commit.last"

    file="${REPO}/.repo/commit.last"
    sha=$(_hash_obj "${file}");
    cp -p "${file}" "${REPO}/.repo/objects/${sha}"

    echo "${sha}" > "${REPO}/.repo/HEAD";
}

log() {
    if [ ! -f "${REPO}/.repo/HEAD" ]; then echo "No commits yet"; return; fi
    sha=$(cat "${REPO}/.repo/HEAD");
    path="${REPO}/.repo/objects/${sha}"

    while [ ! -z "${sha}" ]; do
        echo "commit: ${sha}"
        printf "  "; egrep '^date: ' ${path}
        printf "  "; egrep '^comment: ' ${path}
        echo

        sha=$(egrep -h '^parent: ' "${path}" | awk '{print $2}')
        path="${REPO}/.repo/objects/${sha}"
    done
}
