setup:
    mkdir -p daily/ weekly/ projects/
    touch inbox.md projects.md waiting-for.md someday-maybe.md calendar.md

add-project:
    mkdir -p projects/active/{{project}}
    touch projects/active/{{project}}/info.md projects/active/{{project}}/tasks.md

add-task:
    echo -e "\n" | tod task create --project "{{project}}" --content "{{task}}" --label "@{{context}}" --no-section

add-task-to-project:
    echo -e "\n" | tod task create --project "{{project}}" --content "{{task}}" --label "@{{context}}" --no-section