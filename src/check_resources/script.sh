usage_percentage=$(df -h "$(pwd)" | awk 'NR==2 {print $5}' | tr -d '%')
df -h "$(pwd)"

if [ "$usage_percentage" -gt "$par_threshold" ]; then
    echo "WARNING: Disk usage is at ${usage_percentage}%"
fi