#!/bin/ash
cd $OUT_DIRECTORY

now=$(date  "+%Y%m%d%H")

expiration_date_input="now + ${EXPIRE_AFTER} days"
expiration=$(date -I -d"$expiration_date_input")

PUBLISH="aws sns publish --topic-arn $SNS_TOPIC_ARN --message"

for d in $(ls ./)
do
    if [[ "$now" -gt "$d" ]]; then
	# For each hour thats finished, make sure that a video file has been produced
	filename="$d.mkv"
	if [ ! -f "./$d/$filename" ]; then
	    cat $d/*.jpg | ffmpeg -loglevel error -r 1 -i -  -pix_fmt yuv420p -r 10 $d/$filename
	    if [ ! -f "./$d/$filename" ]; then	
		echo "FFMPEG Encoding did not succeed for video $d"
		if [ ! -f "./$d/.error_notified" ]; then
		    aws sns publish --topic-arn $SNS_TOPIC_ARN --message "FFMPEG Encoding did not succeed for video $d/$filename"
		    touch $d/.error_notified
		fi
	    fi
	fi

	# For each video file created, make sure it is uploaded
	if [[ -f "$d/$filename" ]] && [[ ! -f "$d/.uploaded" ]]; then
	    echo "Uploading $d/$filename to S3, expires on $expiration ($EXPIRE_AFTER days)"

	    object_url=s3://$VIDEO_BUCKET/${d:0:8}/$filename
	    
	    aws s3 cp $d/$filename $object_url --expires $expiration --only-show-errors
	    if [[ $? -eq 0 ]] ; then
		touch $d/.uploaded
	    else
		echo "Upload to S3 failed"
		aws sns publish --topic-arn $SNS_TOPIC_ARN --message "Upload to S3 failed for $d/$filename. Object key: s3://$VIDEO_BUCKET/${d:0:8}/$filename"
	    fi
       fi
    fi
done
