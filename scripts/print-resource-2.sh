resource_id=$1
grain_path=$2
token=$3
contract_path=$CONTRACT_FILE_PATH

# echo "extracting power state attribute from resource"
# will print the attribute "power_state" of the resource
state=$(jq --arg ResourceId "$resource_id" --arg GrainPath "$grain_path" '.resources[] | select(.identifier == $ResourceId and .grain_path == $GrainPath) | .attributes | .power_state' $contract_path)

state_tr=`echo -n $state | tr -d '"'`

echo $state_tr
export $state_tr
