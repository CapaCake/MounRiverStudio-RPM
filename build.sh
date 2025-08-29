#!/bin/bash

# 确保脚本在出错时退出
set -e

DEB_PACKAGE=$(ls MounRiverStudio_Linux_X64_*.deb | head -n 1)

if [ -z "$DEB_PACKAGE" ]; then
    echo "Error: 未找到 MounRiverStudio_Linux_X64_xxx.deb 文件"
    exit 1
fi

echo "找到的 DEB 包: ${DEB_PACKAGE}"

# 从文件名中提取版本信息
VERSION=$(echo "${DEB_PACKAGE}" | grep -oP "V\d+" | grep -oP "\d+")

if [ -z "$VERSION" ]; then
    echo "Error: 无法从文件名提取版本信息"
    exit 1
fi

echo "提取到的版本信息: ${VERSION}"

# 定义其他变量
DATA_PATH="data"
SPEC_FILE_PATH="MounRiverStudio.spec"
RPMBUILD_DIR="$HOME/rpmbuild"
SOURCES_DIR="$RPMBUILD_DIR/SOURCES"
SPECS_DIR="$RPMBUILD_DIR/SPECS"

echo "---正在解压---"
ar x "./${DEB_PACKAGE}"
mkdir -p "${DATA_PATH}"
tar -xf data.tar.* -C "${DATA_PATH}"

echo "---正在修改---"
LOAD_SH_PATH="${DATA_PATH}/usr/share/MRS2/beforeinstall/load.sh"
if [ -f "${LOAD_SH_PATH}" ]; then
    sed -i '2i export LD_LIBRARY_PATH="/usr/share/MRS2/beforeinstall:$LD_LIBRARY_PATH"' "${LOAD_SH_PATH}"
else
    echo "Error: ${LOAD_SH_PATH} 文件不存在"
    exit 1
fi

echo "---修改 SPEC 文件中的版本信息---"
if [ -f "${SPEC_FILE_PATH}" ]; then
    sed -i "s/^Version:.*/Version:        ${VERSION}/" "${SPEC_FILE_PATH}"
else
    echo "Error: ${SPEC_FILE_PATH} 文件不存在"
    exit 1
fi

echo "---重新打包---"
TARBALL_NAME="MounRiverStudio_Linux_X64_V${VERSION}.tar.xz"
tar -cJf "${TARBALL_NAME}" -C "${DATA_PATH}" .

echo "---移动打包文件到 SOURCES 目录---"
mkdir -p "${SOURCES_DIR}"
mv "${TARBALL_NAME}" "${SOURCES_DIR}/"
mkdir -p "${SPECS_DIR}"
cp  "${SPEC_FILE_PATH}" "${SPECS_DIR}"

echo "进入 $HOME 目录"
cd "$HOME"

echo "---开始构建 RPM 包---"
if [ -d "${SPECS_DIR}" ]; then
    rpmbuild -bb "${SPECS_DIR}/MounRiverStudio.spec"
else
    echo "Error: ${SPECS_DIR} 目录不存在"
    exit 1
fi
