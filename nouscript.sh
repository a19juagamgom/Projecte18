#!/bin/bash
#Info per al usuari
usage(){

	echo "Com usar-ho : $0 [-a] [-r] [-d] nomdelUsuari"
	echo "-a És opcional i fa còpia del home a /archives/user.tar.gz"
	echo "-r És opcional i elimina el usuari"
	echo "-d És opcional i deshabilita el usuari"

}
#Guardar id usuari
ObtenirId(){
	id=$(id -u $1)
	check=$?
	if [[ $check -eq 1 ]];then
		echo "Incorrecte:: El usuari "$1" no existeix"
	
	
	elif [[ $id -gt 1000 ]];then
		echo "El usuari "$1" té un id > 1000"
		vulnerabilitat=1
	
	elif [[ $id -lt 1000 ]];then
		echo $id
		echo "El usuari "$1" té un id < 1000."
		echo "No es pot esborrar l'usuari."
	fi
}

#La funció bloqueja l'usuari
bloquejaUsuari(){
	usermod -L $1
	chage -E0 $1
	usermod -s /sbin/nologin $1
	echo "El usuari "$1" s'ha bloquejat "
}

#LA funció esborra l'usuari i la carpeta home.
esborraUsuari(){
	userdel $1
	echo "El usuari s'ha esborrat"
}

#Funció per fer backup de l'usuari
copiaUsuari(){
	userdir=`eval echo ~$1`
	date=`date +"%y-%m-%d-%s"`
	filename=`echo $1"."$date".tar.gz"`
	path=`echo $userdir"/"$filename`
	`cd $userdir`
	`tar -czf $filename .`
	`mv $filename /archives/$filename`
	echo "Còpia del d'usuari feta a /archives/"$filename
}

#Getops
while getopts ":d:r:a:" o; do
	case "${o}" in
	d)
		#Parametre de -d
		usuari=$OPTARG
		ObtenirId $usuari
		if [ "$vulnerabilitat" == 1 ];then
			bloquejaUsuari $usuari
		fi
		;;
	r)
		#Parametre de -r
		usuari=$OPTARG
		ObtenirId $usuari
		if [ "$vulnerabilitat" == 1 ];then
			esborraUsuari $usuari
		fi
		;;
	a)
		#Parametre de -a
		usuari=$OPTARG
		copiaUsuari $usuari
		;;
	:)
		#Si no afegim un paramtre sortirà el case.
		echo "Incorrecte: LA -$OPTARG requereix un paràmetre" 1>&2
		error=$OPTARG
		Fallo=1
		;;
	\?)
		#Si afegim una opció no esmentada
		echo "Incorrecte: Opció no contemplada -$OPTARG" 1>&2
		Fallo=1
		;;
	esac
done

#Si l'usuari no afegeix opció sortirà aquest error.

if [ -z $usuari ] && [ "$error" != "d" ] && [ "$error" != "r"  ] && [ "$error" != "a" ]; then
	echo "Incorrecte: S'ha d'afegir una opció -r, -d, -a" 1>&2
	Fallo=1
fi

#Si hi ha error fallo=1 llavors sortirà del script.
if [ "$Fallo" == 1 ];then
	usage
	exit 1
fi

