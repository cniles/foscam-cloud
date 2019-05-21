#!/bin/ash
cd $OUT_DIRECTORY

now=$(date  "+%Y%m%d%H")
day=$(date  "+%Y%m%d")

expiration_date_input="now + ${EXPIRE_AFTER} days"
expiration=$(date -I -d"$expiration_date_input")

for d in $(ls ./)
do
    if [[ "$now" -gt "$d" ]]; then
	filename="$d.mkv"
	if [ ! -f "./$d/$filename" ]; then
	    cat $d/*.jpg | ffmpeg -loglevel error -r 1 -i -  -pix_fmt yuv420p -r 10 $d/$filename
	    if [ ! -f "./$d/$filename" ]; then	
		echo "FFMPEG Encoding did not succeed for video $d"
	    fi
	fi
	if [[ -f "$d/$filename" ]] && [[ ! -f "$d/.uploaded" ]]; then
	    echo "Uploading $video to S3, expires on $expiration ($EXPIRE_AFTER days)"
	    aws s3 cp $d/$filename s3://$VIDEO_BUCKET/$day/$filename --expires $expiration --only-show-errors
	    if [[ $? -eq 0 ]] ; then
		touch $d/.uploaded
	    else
		echo "Upload to S3 failed"
	    fi
       fi
    fi
done
