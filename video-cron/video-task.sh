#!/bin/ash
cd $OUT_DIRECTORY

now=$(date  "+%Y%m%d%H")
day=$(date  "+%Y%m%d")

expiration_date_input="now + ${EXPIRE_AFTER} days"
expiration=$(date -I -d"$expiration_date_input")

for d in $(ls ./)
do
    filename=$d.mkv
    if [[ "$now" -gt "$d" ]]; then
	if [ ! -f ./$d/$d.mkv ]; then
	    cat $d/*.jpg | ffmpeg -loglevel error -r 1 -i -  -pix_fmt yuv420p -r 10 $d/$filename
	    echo "Uploading $video to S3, expires $expiration ($EXPIRE_AFTER days)"
	    aws s3 cp $d/$filename s3://$VIDEO_BUCKET/$day/$filename --expires $expiration
       fi
    fi
done
