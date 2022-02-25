const crypto = require('crypto');

const { S3Client, CopyObjectCommand } = require('@aws-sdk/client-s3');
const client = new S3Client();

const DST_BUCKET = process.env.DST_BUCKET;

exports.handler = async (event) => {
    // console.log(`Event: ${JSON.stringify(event)}`);
    // TODO: Include metadata -> Cache-Control: no-cache, no-store
    try {
        let item = event.Records[0].s3;
        let srcBucket = item.bucket.name;
        let key = item.object.key;
        let hash = crypto.createHash('md5');
        hash.update(key);
        let prefix = hash.digest('hex');

        let input = {
            CopySource: `${srcBucket}/${key}`,
            Bucket: DST_BUCKET,
            Key: `${prefix}/${key}`
        };
        
        let command = new CopyObjectCommand(input);
        const data = await client.send(command);

        return data;
    } catch (error) {
        console.log(error);
    }
};
