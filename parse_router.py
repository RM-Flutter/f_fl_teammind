import re

with open('lib/core/routing/app_router.dart', 'r') as f:
    lines = f.readlines()

def find_matching_brace(lines, start_line, start_char='{', end_char='}'):
    count = 0
    for i in range(start_line, len(lines)):
        for c in lines[i]:
            if c == start_char: count += 1
            elif c == end_char: count -= 1
            if count == 0: return i
    return -1

# Find start of more route
more_start = -1
for i, line in enumerate(lines):
    if "path: '/:lang/more'" in line:
        # The GoRoute is likely on the line above or a few lines above
        for j in range(i, -1, -1):
            if "GoRoute(" in lines[j]:
                more_start = j
                break
        break

if more_start != -1:
    more_end = find_matching_brace(lines, more_start, '(', ')')
    print(f"more route goes from {more_start} to {more_end}")
else:
    print("Could not find more route")

# Find start of free-services-home
free_start = -1
for i, line in enumerate(lines):
    if "path: 'free-services-home'" in line:
        for j in range(i, -1, -1):
            if "GoRoute(" in lines[j]:
                free_start = j
                break
        break

# Find end of about-team-mind (or mediaCenterYoutubeScreenView)
media_start = -1
for i, line in enumerate(lines):
    if "name: AppRoutes.mediaCenterYoutubeScreenView.name," in line:
        for j in range(i, -1, -1):
            if "GoRoute(" in lines[j]:
                media_start = j
                break
        break

if media_start != -1:
    media_end = find_matching_brace(lines, media_start, '(', ')')
    # The routes array for about-team-mind ends at the next line maybe?
    # Let's just find the closing brace of the array
    print(f"free-services-home starts at {free_start}")
    print(f"mediaCenterYoutubeScreenView ends at {media_end}")
