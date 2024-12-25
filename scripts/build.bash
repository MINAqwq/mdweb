#/bin/bash

on_error() {
    echo -e "\033[31;1;1m\n${1}\033[0m" > /dev/stderr
    exit 1
}

trap "on_error 'USER ABORT'" SIGINT

if [ ! -d scripts ]; then
    on_error "Only run script from project root"
fi

source "scripts/config.bash"
echo -e "\033[35;1;1m======== ${TITLE} by ${AUTHOR} ========\033[0m" > /dev/stderr;

if [[ "${#}" != "1" ]]; then
    echo -e "\033[31;1;1mspecify a out directory!\033[0m\nUsage: build [OUT_DIR]" > /dev/stderr
    exit 2
fi

in_dir="./src" # filepath needs to end without a '/'
out_dir=$1

if [[ ${out_dir} == */ ]]; then
    out_dir="$(dirname $out_dir)/$(basename $out_dir)"
fi

if [[ -d ${out_dir} ]]; then
    if [[ ! -f ${out_dir}/index.html ]]; then
        echo -e "\033[31;1;1m${out_dir} WAS NOT an out directory before!!!!\033[0m" > /dev/stderr;
        exit 2;
    else
        rm -r ${out_dir}
        echo -e "\033[32;1;1m[$SECONDS] delete old out directory...\033[0m" > /dev/stderr;
    fi
fi

md_files_buf=$(find -O3 $in_dir -name "*.md")
echo -e "\n# /${TITLE}/" > "${in_dir}/index.md"
for file in $md_files_buf
do
    base_name=$(basename $file .md)
    echo "- [/${base_name}/]($(dirname $file | sed -e "s%$in_dir%./%g")${base_name}.html)" >> "$in_dir/index.md"
done

for file in $(find -O3 $in_dir -name "*.md")
do
    html_file=$(echo $file | sed -e "s%.md$%.html%g" -e "s%^${in_dir}%${out_dir}%g")

    echo -e "\033[32;1;1m[$SECONDS] + ${html_file}\033[0m" > /dev/stderr;

    mkdir -p $(dirname $html_file)

    echo -n "<!DOCTYPE html><head><title>/${TITLE}/</title>" > $html_file
    echo -n '<meta charset="UTF-8">' >> $html_file
    echo -e -n "<link rel=\"stylesheet\" href=\"/theme.css\">" >> $html_file
    echo -n "<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">" >> $html_file
    echo -n "</head>" >> $html_file

    md2html --github $file >> $html_file || on_error "markdown error"

    echo -n "<footer><hr><p><i>${DOMAIN} by /${AUTHOR}/</i><br>$(date +"%x %I:%m %p")<p></footer>" >> $html_file
done

rm "$in_dir/index.md"

for file in $(find -O3 $in_dir -type f -not -name "*.md")
do
    rfile=$(echo $file | sed -e "s%^${in_dir}/%%g")
    echo -e "\033[32;1;1m[$SECONDS] * ${rfile}\033[0m" > /dev/stderr;
    mkdir -p ${out_dir}/$(dirname $rfile)
    cp ${file} ${out_dir}/${rfile}
done

echo -e "\033[32;1;1m[$SECONDS] copy ${THEME}\033[0m" > /dev/stderr;
cp ${THEME} ${out_dir}/theme.css

echo -e "\033[32;1;1m[$SECONDS] copy ${ROBOTS}\033[0m" > /dev/stderr;
cp ${ROBOTS} ${out_dir}/robots.txt
