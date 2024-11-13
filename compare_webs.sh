#!/bin/bash
#Powered by Jason
WORKSPACE="static/compare_webs/"
VERBOSE=false
DOMAIN=
COMPARE=false
FOLDER_NAME=""


#
# Print help
#
if [ "$1" == "-h" ] || [ "$1" == "--help" ] ; then
	echo ""
	echo "Posible options:"
 	echo "-d --domain Domain name to capture www.example.com"
	echo "-c --compare boolean true false | if only capture or capture now and compare with last captured"
	echo "-v --verbose boolean true false | print info throw the process"
	echo ""
	exit 0
fi

# Use > 1 to consume two arguments per pass in the loop (e.g. each
# argument has a corresponding value to go with it).
# Use > 0 to consume one or more arguments per pass in the loop (e.g.
# some arguments don't have a corresponding value to go with it such
# as in the --default example).
# note: if this is set to > 0 the /etc/hosts part is not recognized ( may be a bug )
while [[ $# > 1 ]]
do
key="$1"
case $key in
	-d|--domain)
    		DOMAIN="$2"
    	shift # past argument
    	;;
    	-c|--compare)
    		COMPARE="$2"
    	shift # past argument
    	;;
    	-v|--verbose)
    		VERBOSE="$2"
    	shift # past argument
    	;;
    	--default)
    		DEFAULT=YES
    	;;
    	*)
    		# unknown option
    	;;
esac
shift # past argument or value
done

#
# function that return the correct json to parse from python
#
function sendReturn {
	# status: 0 ok | 1 changes in img need report | 2: error 
	echo '{"status": '$1', "msg": "'$2'", "file_new": "'$3'", "file_old": "'$4'", "file_compared": "'$5'"}'
}


#
# Check all params needed are correct
#

if [ -z $DOMAIN ]; then
	sendReturn "2" "No domain argument passed" "" "" ""
	exit 1
fi

#
# Name for new screenshot img
#
NEW_FILE_NAME=$(date +"%Y%m%d%T" | sed 's/[\.:_-]//g')

#
# Folder where to save screenshot img
#
FOLDER_NAME=$DOMAIN 

#
# if the folder dosn't exist create it
#
if [ ! -d "$WORKSPACE/$FOLDER_NAME" ]; then
	mkdir -p $WORKSPACE/$FOLDER_NAME
fi

#
# Verbose info
#
if $VERBOSE ; then
	echo "Domain: " $DOMAIN " compare: " $COMPARE
	echo "Workspace and folder saved: " $WORKSPACE/$FOLDER_NAME 
fi

#
# Check if compare screenshot with older or only make screenshot
#

if $COMPARE ; then

	# Get last created
	LAST_CREATED=$(ls $WORKSPACE/$FOLDER_NAME -I 'compared_*' -t | head -1)

	#
	# capture now
	#
	$(cutycapt --url=$DOMAIN --out=$WORKSPACE/$FOLDER_NAME/$NEW_FILE_NAME.png --min-height=2000 --min-width=1280)
	#
	# compare with captured
	#
	compared_value=$((compare -metric MAE "$WORKSPACE/$FOLDER_NAME/$LAST_CREATED" "$WORKSPACE/$FOLDER_NAME/$NEW_FILE_NAME.png" "$WORKSPACE/$FOLDER_NAME/compared_$NEW_FILE_NAME.png") 2>&1)

	#	
	# verbose info
	#	
	if $VERBOSE ; then
		echo "Last file created:            $LAST_CREATED"
		echo "New file created:             $NEW_FILE_NAME.png"
		echo "New file compared:            compared_$NEW_FILE_NAME.png"
		echo "Returned value from compared: $compared_value"
	fi

	if [ "$compared_value" != "0 (0)" ] ; then 
		sendReturn "1" "Differences found" "$WORKSPACE/$FOLDER_NAME/$NEW_FILE_NAME.png" "$WORKSPACE/$FOLDER_NAME/$LAST_CREATED" "$WORKSPACE/$FOLDER_NAME/compared_$NEW_FILE_NAME.png"	
	else
		sendReturn "0" "No differences found" "$WORKSPACE/$FOLDER_NAME/compared_$NEW_FILE_NAME.png" "$WORKSPACE/$FOLDER_NAME/$LAST_CREATED" ""
	fi

else

	#
	#capture_only
	#
	$(cutycapt --url=$DOMAIN --out=$WORKSPACE/$FOLDER_NAME/$NEW_FILE_NAME.png --min-height=2000 --min-width=1280)
	
	sendReturn "0" "new image captured" "$WORKSPACE/$FOLDER_NAME/$NEW_FILE_NAME.png" "" ""

	# verbose info
	#if $VERBOSE ; then
		
	#echo "1"
	#fi
fi


