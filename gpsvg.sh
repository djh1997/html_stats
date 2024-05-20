#!/bin/bash

# Function to convert GPS coordinates to SVG coordinates
gps_to_svg() {
    local lat=$1
    local lon=$2
    local scale=$3
    local offset_x=$4
    local offset_y=$5
    
    # Simple scaling and offset
    local svg_x=$(echo "$lon * $scale + $offset_x" | bc -l)
    local svg_y=$(echo "$lat * $scale + $offset_y" | bc -l)
    
    echo "$svg_x $svg_y"
}

# Check if correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: $0 input.csv output.svg"
    exit 1
fi

input_csv=$1
output_svg=$2

# SVG setup
scale=10  # Adjust as necessary
offset_x=100  # Adjust as necessary
offset_y=100  # Adjust as necessary

# Initialize SVG content
svg_header="<?xml version=\"1.0\" standalone=\"no\"?>\n"
svg_header+="<!DOCTYPE svg PUBLIC \"-//W3C//DTD SVG 1.1//EN\" \"http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd\">\n"
svg_header+="<svg width=\"800\" height=\"600\" version=\"1.1\" xmlns=\"http://www.w3.org/2000/svg\">\n"
svg_header+="<path d=\""

# Read CSV and create SVG path
path_data=""
first_point=true

while IFS=, read -r lat lon; do
    # Convert GPS coordinates to SVG coordinates
    svg_coords=$(gps_to_svg $lat $lon $scale $offset_x $offset_y)
    
    if $first_point; then
        path_data+="M $svg_coords"
        first_point=false
    else
        path_data+=" L $svg_coords"
    fi
done < "$input_csv"

# Finalize SVG content
svg_footer="\" fill=\"none\" stroke=\"black\" stroke-width=\"2\" />\n"
svg_footer+="</svg>"

# Write SVG to output file
echo -e "$svg_header$path_data$svg_footer" > "$output_svg"

echo "SVG path written to $output_svg"