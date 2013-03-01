#!/bin/bash

# Папка, в которой лежит скрипт и плейлист
cd ./Музыка/script/

# Читаем плейлист
plst=$(ls | grep '\.m3u')
if [ -z $plst ]; then echo нет ни одного файла с плейлистом с расширением m3u. выходим - не счем работать.; exit 0; fi 
 
# Даем пользователю выбрать, если плейлистов больше одного
if [ `ls | grep '\.m3u' | wc -l` -gt 1 ]; then echo "больше одного плейлиста в этом каталоге, какой плейлист желаете распарзить?";
select var in `ls | grep '\.m3u'`
        do 
        echo
        echo "Вы выбрали → $var"
        plst=$var
        echo
        break  # если 'break' убрать, то получится бесконечный цикл.;
        done
fi
 
# Сохраняем предидущую версию плейлиста, разбитого на ссылки и названия треков
if [ -z $(ls | grep links.old) ]; then echo нет файла links.old создаю....; touch links.old; fi; 
if [ -z $(ls | grep names.old) ]; then echo нет файла names.old создаю....; touch names.old; fi;
mv links links.old
mv names names.old

# Проверка на сущестование папки, куда скачиваются треки.
if [ -d noname ]; then echo Папка для скачанных треков уже существует; else mkdir noname; fi;


# Разбираем плейлист
cat $plst | grep -o "http://.*\.mp3" | sed 's/\(http:.*\.mp3\)\(?.*\)/\1/' > links
cat $plst | grep EXTINF | sed 's/^#EXTINF:[0-9]*,\(.*\)$/\1/' | sed 's/\(&#38;#38;#[0-9]*;\)\|\/\|\\\|:\|\*\|\?\|\"\|<\|>\||//g' | cut -c -127 > names1
a=10000
b=$(grep '.' names1 | wc -l)
c=$(($a - $b))

#сохраняем файл в нормальной кодировке
iconv -f WINDOWS-1251 -t UTF-8 -o names2 names1 

#удаляем все лишнее
sed -e 's/^#EXTINF[0-9]*,//g'  names2 > names3
sed -e 's/&#[0-9]*;//g'  names3 > names4
sed -e 's/    - / - /g'  names4 > names
rm names1
rm names2
rm names3
rm names4

# Ищем какие треки скачивать (только последние добавленные, пока не отслеживается, если треки удалены из плейлиста.)
diff names names.old | grep "<" | sed 's/< //g' > .to_rename
(( audio=$(cat .to_rename | wc -l)+1 ))
(( allurl=$(cat links | wc -l) ))
cat $plst | grep -o "http://.*\.mp3" | sed 's/\(http:.*\.mp3\)\(?.*\)/\1/' > .to_mv
sed -i $audio,$allurl'd' .to_mv

# Проверяем добавились ли треки
if [ $(cat .to_mv | wc -l) = 0 ]; then echo треков не добавилось - выходим; exit 0; fi 

# Скачиваем
cd noname
wget -c -i ../.to_mv
#wget -c --wait=60 --waitretry=10 -i .to_mv # пауза в СЕКУНДАХ между загрузками чтобы не забанили... ну для параноиков

# Лог
cd ..
date >> log
cat .to_mv >> log

# Переименовываем
if [ $(cat .to_rename | wc -l) = 0 ]; then echo "нет имён файлов - выходим, иначе все то, что накачали потеряется";exit; fi
LINES=$(cat .to_mv | wc -l)
for i in $(seq $LINES); do
        FILE=$(head -n 1 .to_mv | sed 's/^.*\///')
        NAME=$(head -n 1 .to_rename | sed "s/\r//g")
        sed -i 1d .to_mv
        sed -i 1d .to_rename
        cp -l "noname/$FILE" "../$NAME.mp3" #так будут дубликаты как в плейлисте, вдруг Вы спецом так захотели
  rm noname/$FILE
done

# Удаляем лишние файлы
rm .to_mv
rm .to_rename
rm noname

# Выводим сообщение пользователю


if [[ `gdialog` == "" ]]; then messager="gdialog --msgbox"; elif [[ `kdialog` == "" ]]; then messager="kdialog --msgbox"; else messager=echo; fi; echo $messager;
$messager "Успешно загружено $LINES файлов"; # у кого k, а кого и g :)))

exit 0
