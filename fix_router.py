with open('lib/core/routing/app_router.dart', 'r') as f:
    text = f.read()

# We need to find the `more` GoRoute
# It starts with:
#           GoRoute(
#             path: '/:lang/more',
# We need to parse it using a brace counter.
start_idx = text.find("GoRoute(\n            path: '/:lang/more'")
if start_idx == -1:
    print("Could not find more route")
    exit()

count = 0
end_idx = -1
for i in range(start_idx, len(text)):
    if text[i] == '(':
        count += 1
    elif text[i] == ')':
        count -= 1
        if count == 0:
            end_idx = i
            break

print(f"more route goes from {start_idx} to {end_idx}")

# Now inside this more_route block, we need to extract the free services routes.
# The free services start at "              GoRoute(\n                path: 'free-services-home',"
free_services_start_idx = text.find("GoRoute(\n                path: 'free-services-home',", start_idx, end_idx)

# And they end after "youtube-video/:url"
youtube_idx = text.find("GoRoute(\n                path: 'youtube-video/:url',", free_services_start_idx, end_idx)

count = 0
youtube_end_idx = -1
for i in range(youtube_idx, end_idx):
    if text[i] == '(': count += 1
    elif text[i] == ')':
        count -= 1
        if count == 0:
            youtube_end_idx = i
            break

# We want to extract the whole block from free_services_start_idx to youtube_end_idx + 1 (plus any trailing commas)
extract_end = text.find(",", youtube_end_idx)
if extract_end == -1 or extract_end > youtube_end_idx + 10:
    extract_end = youtube_end_idx

extracted_block = text[free_services_start_idx:extract_end+1]

# Now remove the extracted block from the original text
new_text = text[:free_services_start_idx] + text[extract_end+1:]

# Insert the extracted block after the more route
# But wait, end_idx has changed because we removed text before it!
# It's better to just replace the extracted block with empty string, 
# then find the end of more route again, and insert.

# But there might be formatting/indentation issues.
# Extracted block is indented by 14 spaces. 
# As siblings of more (which is indented by 10 spaces), they should also be indented by 10 spaces.
# Let's fix the indentation of extracted block.
lines = extracted_block.split('\n')
dedented_lines = []
for line in lines:
    if line.startswith('    '):
        dedented_lines.append(line[4:])
    else:
        dedented_lines.append(line)

final_extracted = '\n'.join(dedented_lines)

# Insert after more route
more_start_idx = new_text.find("GoRoute(\n            path: '/:lang/more'")
count = 0
new_end_idx = -1
for i in range(more_start_idx, len(new_text)):
    if new_text[i] == '(': count += 1
    elif new_text[i] == ')':
        count -= 1
        if count == 0:
            new_end_idx = i
            break

# Find the comma after more route end
comma_idx = new_text.find(",", new_end_idx)
insert_pos = comma_idx + 1 if comma_idx != -1 and comma_idx < new_end_idx + 10 else new_end_idx + 1

final_text = new_text[:insert_pos] + '\n' + final_extracted + new_text[insert_pos:]

with open('lib/core/routing/app_router.dart_fixed', 'w') as f:
    f.write(final_text)

print("Done. Wrote to app_router.dart_fixed")
