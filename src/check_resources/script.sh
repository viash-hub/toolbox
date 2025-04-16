usage_percentage=$(df -h "$(pwd)" | awk 'NR==2 {print $5}' | tr -d '%')
df -h "$(pwd)"

max_allowed_usage=$((100-par_req_disk_space))
if [ "$usage_percentage" -gt "$max_allowed_usage" ]; then
    echo "WARNING: Disk usage is at ${usage_percentage}%, exceeding maximum allowed usage of ${max_allowed_usage}%"
fi