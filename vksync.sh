#!/bin/bash
cd ./Музыка/script/
plst=$(ls | grep '\.m3u')
if [ -z $plst ]; then echo нет ни одного файла с плейлистом с расширением m3u. выходим - не счем работать.; exit 0; fi # Если файла с плейлистом нет, то выходим. Не счем работать.
 
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
 
if [ -z $(ls | grep links.old) ]; then echo нет файла links.old создаю....; touch links.old; fi; 
if [ -z $(ls | grep names.old) ]; then echo нет файла names.old создаю....; touch names.old; fi;
 

#mkdir noname
mv links links.old
mv names names.old
cat $plst | grep -o "http://.*\.mp3" | sed 's/\(http:.*\.mp3\)\(?.*\)/\1/' > links
cat $plst | grep EXTINF | sed 's/^#EXTINF:[0-9]*,\(.*\)$/\1/' | sed 's/\(&#38;#38;#[0-9]*;\)\|\/\|\\\|:\|\*\|\?\|\"\|<\|>\||//g' | cut -c -127 > names1
a=10000
b=$(grep '.' names1 | wc -l)
c=$(($a - $b))
iconv -f WINDOWS-1251 -t UTF-8 -o names2 names1
sed -e 's/^#EXTINF[0-9]*,//g'  names2 > names3
sed -e 's/&#[0-9]*;//g'  names3 > names4
sed -e 's/    - / - /g'  names4 > names
diff links links.old | grep "<" | sed 's/< //g' | sed 's/\s/\n/g' > .to_mv
if [ -z $(cat .to_mv) ]; then echo треков не добавилось - выходим; exit 0; fi #Если треков не добавилось - выходим
diff names names.old | grep "<" | sed 's/< //g' > .to_rename
cp .to_mv noname
cd noname
wget -c -i .to_mv
#wget -c --wait=60 --waitretry=10 -i .to_mv # пауза в СЕКУНДАХ между загрузками чтобы не забанили... ну для параноиков
cd ..
date >> log
cat .to_mv >> log
if [ $(cat .to_rename | wc -l) = 0 ]; then echo "нет имён файлов - выходим, иначе все то, что накачали потеряется";exit; fi
LINES=$(cat .to_mv | wc -l)
for i in $(seq $LINES); do
        FILE=$(head -n 1 .to_mv | sed 's/^.*\///')
        NAME=$(head -n 1 .to_rename | sed "s/\r//g")
        sed -i 1d .to_mv
        sed -i 1d .to_rename
        #mv "$FILE" "$NAME.mp3"
        cp -l "noname/$FILE" "../$NAME.mp3" #так будут дубликаты как в плейлисте, вдруг Вы спецом так захотели
  rm noname/$FILE
done
rm .to_mv
rm .to_rename
rm names1
rm names2
rm names3
rm names4
if [[ `gdialog` == "" ]]; then messager="gdialog --msgbox"; elif [[ `kdialog` == "" ]]; then messager="kdialog --msgbox"; else messager=echo; fi; echo $messager;
$messager "Успешно загружено $LINES файлов"; # у кого k, а кого и g :)))
exit 0