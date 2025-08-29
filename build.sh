#!/bin/bash

set -e

if [ -z "${VERSION}" ]; then
    echo "Error: VERSION 环境变量未定义，脚本无法继续运行。"
    exit 1
fi
echo "Version ${VERSION}"
DEB_FILE="MounRiverStudio_Linux_X64_V${VERSION}.deb"
DEB_URL="https://github.com/CapaCake/MounRiverStudio-RPM/releases/download/original_v${VERSION}/${DEB_FILE}"

SPEC_FILE_PATH="MounRiverStudio.spec"
RPMBUILD_DIR="$HOME/rpmbuild"
SOURCES_DIR="$RPMBUILD_DIR/SOURCES"
SPECS_DIR="$RPMBUILD_DIR/SPECS"

mkdir -p "${SOURCES_DIR}"
mkdir -p "${SPECS_DIR}"

# 下载 DEB 文件（如果不存在）并移动到 SOURCES 目录
if [ ! -f "${SOURCES_DIR}/${DEB_FILE}" ]; then
    echo "DEB 文件不存在，开始下载..."
    # 直接下载到 SOURCES 目录
    curl -L -o "${SOURCES_DIR}/${DEB_FILE}" "${DEB_URL}"
else
    echo "DEB 文件已存在于 SOURCES 目录。"
fi


echo "---修改 SPEC 文件中的版本信息---"
if [ -f "${SPEC_FILE_PATH}" ]; then
    # 使用临时文件进行修改，然后复制到 SPECS 目录
    TMP_SPEC=$(mktemp)
    cp "${SPEC_FILE_PATH}" "${TMP_SPEC}"
    sed -i "s/^Version:.*/Version:        ${VERSION}/" "${TMP_SPEC}"
    mv "${TMP_SPEC}" "${SPECS_DIR}/MounRiverStudio.spec"
else
    echo "Error: ${SPEC_FILE_PATH} 文件不存在"
    exit 1
fi

echo "进入 $HOME 目录"
cd "$HOME"

echo "---开始构建 RPM 包---"
if [ -d "${SPECS_DIR}" ]; then
    rpmbuild -bb "${SPECS_DIR}/MounRiverStudio.spec"
else
    echo "Error: ${SPECS_DIR} 目录不存在"
    exit 1
fi

echo "--- 构建完成 ---"
