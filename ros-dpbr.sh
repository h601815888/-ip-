name: Merge IP List

on:
  schedule:
    - cron: "0 3 * * *"   # 每天自动跑（UTC时间）
  workflow_dispatch:       # 也可以手动触发

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Download IP Lists
      run: |
        mkdir work
        cd work

        # 下载两个来源（自己改URL）
        wget -q -O CN1.rsc https://raw.githubusercontent.com/soffchen/GeoIP2-CN/release/CN-ip-cidr.txt
        wget -q -O CN2.rsc https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt

    - name: Extract and Merge IPv4
      run: |
        cd work

        # 提取 address 字段
        cat CN1.rsc CN2.rsc \
        | grep 'address=' \
        | sed -E 's/.*address=([^ ]+).*/\1/' \
        | sort -u > CN.txt

    - name: Generate RSC
      run: |
        cd work

        {
        echo "/ip firewall address-list"
        while read net; do
          echo "add list=CN address=$net comment=auto"
        done < CN.txt
        } > ../CN.rsc

    - name: Commit & Push
      run: |
        git config --global user.name "github-actions"
        git config --global user.email "actions@github.com"

        git add CN.rsc
        git commit -m "auto update CN list" || echo "no changes"
        git push
