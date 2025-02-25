# Generate Repo File List GitHub Action

This GitHub Action generates an HTML file list for a GitHub repository with links to each file. It updates the `README.md` file with the generated file list.

## Usage

To use this action, create a workflow file (e.g., `.github/workflows/main.yml`) in your repository with the following content:

Place `2` file markers in your README.md: `<!-- FILE_LIST_START -->` and `<!-- FILE_LIST_END -->` - the file list will be automatically added between these 2 points in your `README.md`

Remove the `cron` job if you don't want to run the action daily.
You can also remoove the `push` and `pull_request` triggers if you only want to run the action manually.

If you don't want to have your `README.md` updated automatically, you can remove the "Commit and push changes" and "Update README.md" steps. You can then use the generated `file_list.md` file to update your `README.md` manually (or for any other purpose).

Inputs are described in the [Inputs](#inputs) section.

Example of HTML file list: [HTML File List Example](example-of-the-generated-file-list-in-html-format-without-codeblock)

Example of Markdown file list: [Markdown File List Example](#example-of-the-generated-file-list-in-markdown-format-without-codeblock)

```yaml
name: Generate and Update README.MD File List

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main
  schedule:
    - cron: "0 0 * * *" # Runs once a day at 00:00 UTC
  workflow_dispatch: # Allows manual triggering

permissions:
  contents: write
  pull-requests: write

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v4

      - name: List files in the repository
        run: |
          ls -al

      - name: Verify README.md exists
        run: |
          if [ ! -f README.md ]; then
            echo "README.md not found!"
            exit 1
          fi

      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: "3.x"

      - name: Create src directory
        run: mkdir -p src

      - name: Download generate_file_list.py
        run: |
          curl -L -o src/generate_file_list.py https://github.com/Nick2bad4u/generate-repo-file-list/raw/refs/heads/main/src/generate_file_list.py
          chmod +x src/generate_file_list.py

      - name: Download requirements.txt
        run: |
          curl -L -o requirements.txt https://github.com/Nick2bad4u/generate-repo-file-list/raw/refs/heads/main/requirements.txt
          chmod +x requirements.txt

      - name: Install dependencies (if any)
        run: |
          python -m pip install -r requirements.txt
          # Add any dependencies your script needs here
          # For example: pip install requests

      - name: Run Generate Repo File List Action
        uses: nick2bad4u/generate-repo-file-list@main
        with:
          log-level: "INFO"
          directory: "."
          repo-url: "https://github.com/${{ github.repository }}"
          fallback-repo-url: "https://github.com/${{ github.repository }}"
          output-format: "markdown"
          output-file: "file_list.md"
          color-source: "random"
          color-list: "#FF0000 #00FF00 #0000FF #FFFF00 #FF00FF #00FFFF"
          color-range-start: "#000000"
          color-range-end: "#FFFFFF"
          max-attempts: "1000000"
          exclude-blacks-threshold: "#222222"
          exclude-dark-colors: "false"
          exclude-bright-colors: "false"
          exclude-blacks: "false"
          ensure-readable-colors: "false"
          repo-root-header: "Repo Root"
          header-text: "## File List"
          intro-text: "# Here is a list of files included in this repository:"
          dark-color-luminance-threshold: "128"
          bright-color-luminance-threshold: "200"
          chunk-size: "40"
          viewport-mobile: "768"
          viewport-tablet: "1024"
          viewport-small-desktop: "1440"
          root-margin-large-desktop: "0px 0px 400px 0px"
          root-margin-small-desktop: "0px 0px 300px 0px"
          root-margin-tablet: "0px 0px 200px 0px"
          root-margin-mobile: "0px 0px 100px 0px"

      - name: Update README.md
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const readmePath = './README.md';
            const fileListPath = './file_list.md';

            try {
              // Check if README.md exists, if not create it
              if (!fs.existsSync(readmePath)) {
              console.warn('README.md not found. Creating a new README.md file.');
              fs.writeFileSync(readmePath, '# Project Title\n\n<!-- FILE_LIST_START -->\n<!-- FILE_LIST_END -->\n');
              }

              // Read the contents of README.md
              let readmeContent = fs.readFileSync(readmePath, 'utf8');

              // Read the contents of file_list.md
              const fileListContent = fs.readFileSync(fileListPath, 'utf8');

              // Define start and end markers for the file list section
              const startMarker = '<!-- FILE_LIST_START -->';
              const endMarker = '<!-- FILE_LIST_END -->';

              // Find the start and end positions of the file list section
              const startPosition = readmeContent.indexOf(startMarker);
              const endPosition = readmeContent.indexOf(endMarker);

              // Check if the markers exist in the README.md file
              if (startPosition === -1 || endPosition === -1) {
                console.warn('Start or end markers not found in README.md.  The action will add the markers with the file list to the end of the file.');
                readmeContent += `\n${startMarker}\n${fileListContent}\n${endMarker}\n`;
              } else {
                // Replace the existing file list with the new content
                readmeContent = readmeContent.substring(0, startPosition + startMarker.length) +
                  '\n' + fileListContent + '\n' +
                  readmeContent.substring(endPosition);
              }

              // Write the updated content back to README.md
              fs.writeFileSync(readmePath, readmeContent);
              console.log('Successfully updated README.md');
            } catch (error) {
              console.error('Failed to update README.md:', error);
            }

      - name: Commit and push changes
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "Update file list in README.md automatically with GitHub Action"
          file_pattern: "README.md file_list.md"
          commit_user_name: "{{ github.actor }}"
          commit_user_email: "{{ github.actor }}@users.noreply.github.com"
          commit_author: "{{ github.actor }} <{{ github.actor }}@users.noreply.github.com>"

```

### Inputs

#### The inputs for the action are defined in the `with` section of the action step

#### You can customize the inputs based on your requirements

#### The most common inputs to change are the `repo-url`, `fallback-repo-url`, `output-format`, and `output-file`

#### If you want to change the output format to HTML, set `output-format` to `html`. This will generate an HTML file list instead of a Markdown file list, which provides better styling and interactivity for web viewing or GitHub Pages deployment. HTML format allows for more customization, and also enables you to color file links, and use lazy loading for large file lists

#### The following inputs can be used with the action

```markdown
- `log-level`: Set the logging level setting manually instead of pulling from the environment. Possible values are `DEBUG`, `INFO`, `WARN`, `ERROR`. Default is `INFO`.
- `directory`: Root directory of the repository to generate the file list for. Default is the current directory.
- `repo-url`: GitHub repository URL to use for generating file links. Default is determined by the Git configuration.
- `fallback-repo-url`: Fallback GitHub repository URL to use if the default URL cannot be determined. Default is `https://github.com/${{ github.repository }}`.
- `output-format`: File format to be output in. Possible values are `markdown` and `html`. Default is `markdown`.
- `output-file`: Name of the output file to save the generated file list. The file extension should match the `output-format` (e.g., `file_list.md` for Markdown, `file_list.html` for HTML). Default is `file_list.md`.
- `color-source`: Source of colors for the file links. Choose `random` for randomly generated colors or `list` to use a predefined list of colors. Default is `random`.
- `color-list`: List of colors to use when the color source is set to `list`. Provide colors in hex format (e.g., `#FF0000`). Default is `#FF0000 #00FF00 #0000FF #FFFF00 #FF00FF #00FFFF`.
- `color-range-start`: Start of the range of colors (hex code) for random color generation (e.g., `#000000`). Default is `#000000`.
- `color-range-end`: End of the range of colors (hex code) for random color generation (e.g., `#FFFFFF`). Default is `#FFFFFF`.
- `max-attempts`: Maximum number of attempts to generate a valid color. Default is `1000000`.
- `exclude-blacks-threshold`: Threshold for excluding black colors. Any color below this threshold on the color chart will be excluded (e.g., `#222222`). Default is `#222222`.
- `exclude-dark-colors`: Exclude dark colors from being used for file links. Use this option to avoid dark colors. Default is `false`.
- `exclude-bright-colors`: Exclude bright colors from being used for file links. Use this option to avoid bright colors. Default is `false`.
- `exclude-blacks`: Exclude black colors below a certain threshold from being used for file links. Use this option to avoid very dark colors. Default is `false`.
- `ensure-readable-colors`: Ensure that the generated colors are readable by maintaining a certain contrast ratio with a white background. Default is `false`.
- `repo-root-header`: Header text for files located in the root of the repository. Default is `Repo Root`.
- `header-text`: Header text for the file list displayed at the top of the generated HTML file. Default is `## File List`.
- `intro-text`: Introductory text for the file list displayed below the header in the generated HTML file. Default is `# Here is a list of files included in this repository:`.
- `dark-color-luminance-threshold`: Luminance threshold for determining if a color is dark. Colors with luminance below this value will be considered dark. Default is `128`.
- `bright-color-luminance-threshold`: Luminance threshold for determining if a color is bright. Colors with luminance above this value will be considered bright. Default is `200`.
- `chunk-size`: Number of lines per chunk for lazy loading the file list. Default is `40`.
- `viewport-mobile`: Viewport size for mobile devices in pixels. Default is `768`.
- `viewport-tablet`: Viewport size for tablets in pixels. Default is `1024`.
- `viewport-small-desktop`: Viewport size for small desktops in pixels. Default is `1440`.
- `root-margin-large-desktop`: Root margin for the IntersectionObserver for large desktop viewport. Default is `0px 0px 400px 0px`.
- `root-margin-small-desktop`: Root margin for the IntersectionObserver for small desktops. Default is `0px 0px 300px 0px`.
- `root-margin-tablet`: Root margin for the IntersectionObserver for tablets. Default is `0px 0px 200px 0px`.
- `root-margin-mobile`: Root margin for the IntersectionObserver for mobile devices. Default is `0px 0px 100px 0px`.
```

# Below is an example of the generated file list in Markdown format

```markdown
# ## File List

# Here is a list of files included in this repository:

## Repo Root

- [.gitignore](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/.gitignore)
- [dockerfile](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/dockerfile)
- [file_list.html](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/file_list.html)
- [readme.html](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/readme.html)
- [README.md](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/README.md)
- [file_list.md](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/file_list.md)
- [requirements.txt](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/requirements.txt)

## YAML

- [.github/workflows/main.yml](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/.github/workflows/main.yml)
- [action.yml](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/action.yml)

## src

- [src/generate_file_list.py](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/src/generate_file_list.py)
```

## Example of the Generated File List in Markdown Format (Without Codeblock)

<!-- FILE_LIST_START -->

### ## File List

### Here is a list of files included in this repository

### ## Repo Root

- [.gitignore](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/.gitignore)
- [dockerfile](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/dockerfile)
- [file_list.html](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/file_list.html)
- [readme.html](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/readme.html)
- [README.md](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/README.md)
- [file_list.md](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/file_list.md)
- [requirements.txt](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/requirements.txt)

### ## YAML

- [.github/workflows/main.yml](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/.github/workflows/main.yml)
- [action.yml](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/action.yml)

### ## src

- [src/generate_file_list.py](https://github.com/Nick2bad4u/generate-repo-file-list/blob/main/src/generate_file_list.py)
<!-- FILE_LIST_END -->

# Below is an example of the generated file list in HTML format

```html

# ## File List

# Here is a list of files included in this repository:

<li><h2>Repo Root</h2></li>
<li><a href="https://github.com/author/repo/blob/main/.gitignore" style="color: #44ed0b;">.gitignore</a></li>
<li><a href="https://github.com/author/repo/blob/main/README.md" style="color: #a38c7a;">README.md</a></li>
<li><a href="https://github.com/author/repo/blob/main/dockerfile" style="color: #31e38c;">dockerfile</a></li>
<li><a href="https://github.com/author/repo/blob/main/file_list.html" style="color: #38ccce;">file_list.html</a></li>
<li><a href="https://github.com/author/repo/blob/main/file_list.md" style="color: #24ef06;">file_list.md</a></li>
<li><a href="https://github.com/author/repo/blob/main/readme.html" style="color: #40f616;">readme.html</a></li>
<li><a href="https://github.com/author/repo/blob/main/requirements.txt" style="color: #9eb57c;">requirements.txt</a></li>
<li><h2>YAML</h2></li>
<li><a href="https://github.com/author/repo/blob/main/.github/workflows/main.yml" style="color: #c39504;">.github/workflows/main.yml</a></li>
<li><a href="https://github.com/author/repo/blob/main/action.yml" style="color: #b689b8;">action.yml</a></li>
<li><h2>src</h2></li>
<li><a href="https://github.com/author/repo/blob/main/src/generate_file_list.py" style="color: #f8b688;">src/generate_file_list.py</a></li>
</ul>
```

## Example of the Generated File List in HTML Format (Without Codeblock)

### If this is viewed on Github, you wont see the proper formatting, check our github-pages URL to see the proper formatting

## ## File List

## Here is a list of files included in this repository

<li><h2>Repo Root</h2></li>
<li><a href="https://github.com/author/repo/blob/main/.gitignore" style="color: #44ed0b;">.gitignore</a></li>
<li><a href="https://github.com/author/repo/blob/main/README.md" style="color: #a38c7a;">README.md</a></li>
<li><a href="https://github.com/author/repo/blob/main/dockerfile" style="color: #31e38c;">dockerfile</a></li>
<li><a href="https://github.com/author/repo/blob/main/file_list.html" style="color: #38ccce;">file_list.html</a></li>
<li><a href="https://github.com/author/repo/blob/main/file_list.md" style="color: #24ef06;">file_list.md</a></li>
<li><a href="https://github.com/author/repo/blob/main/readme.html" style="color: #40f616;">readme.html</a></li>
<li><a href="https://github.com/author/repo/blob/main/requirements.txt" style="color: #9eb57c;">requirements.txt</a></li>
<li><h2>YAML</h2></li>
<li><a href="https://github.com/author/repo/blob/main/.github/workflows/main.yml" style="color: #c39504;">.github/workflows/main.yml</a></li>
<li><a href="https://github.com/author/repo/blob/main/action.yml" style="color: #b689b8;">action.yml</a></li>
<li><h2>src</h2></li>
<li><a href="https://github.com/author/repo/blob/main/src/generate_file_list.py" style="color: #f8b688;">src/generate_file_list.py</a></li>
</ul>
