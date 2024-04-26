using HTTP
using JSON
using Downloads

# Define constants
const API_ENDPOINT = "https://api.openai.com/v1/images/generations"
const API_KEY = "your_api_key_here"
const CONTENT_TYPE = "application/json"
const AUTHORIZATION = "Authorization"
const BEARER = "Bearer"

# Define the image generation function
function generate_image(prompt::String; n::Int=1, size::String="1024x1024", save_to_file::Bool=false, output_dir::String=".", show_image::Bool=false, response_format::String="url")
    # Define the request payload
    payload = Dict(
        "prompt" => prompt,
        "n" => n,
        "size" => size,
        "response_format" => response_format
    )

    # Set the request headers
    headers = Dict(
        "Content-Type" => CONTENT_TYPE,
        AUTHORIZATION => "$(BEARER) $(API_KEY)"
    )

    # Send the API request and handle errors
    response = try
        HTTP.post(API_ENDPOINT, headers=headers, body=JSON.json(payload))
    catch e
        error("Error occurred during API request: $e")
    end

    # Parse the response
    response_dict = JSON.parse(String(response.body))
    image_urls = [data["url"] for data in response_dict["data"]]

    # Download and save the images if requested
    if save_to_file
        for (i, url) in enumerate(image_urls)
            Downloads.download(url, joinpath(output_dir, "generated_image_$(i).jpg"))
        end
    end

    # Display the generated images if requested
    if show_image
        for url in image_urls
            display(Downloads.download(url))
        end
    end

    return image_urls
end