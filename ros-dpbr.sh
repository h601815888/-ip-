name: Merge IPv4 Address List

on:
  schedule:
    - cron: "0 3 * * *"   # 每天自动运行（UTC时间）
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout
      uses: actions/checkout@v4

    - name: Download Source Files
      run: |
        mkdir work
        cd work

        # 👉 改成你的两个来源
        wget -q -O CN1.rsc https://raw.githubusercontent.com/soffchen/GeoIP2-CN/release/CN-ip-cidr.txt
        wget -q -O CN2.rsc https://raw.githubusercontent.com/mayaxcn/china-ip-list/master/chnroute.txt

        echo "=== 下载完成 ==="
        ls -lh

    - name: Extract IPv4 and Deduplicate
      run: |
        cd work

        # 提取 address 字段（兼容所有格式）
        cat CN1.rsc CN2.rsc \
        | grep -oE 'address=[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+' \
        | cut -d= -f2 \
        | sort -u > CN.txt

        echo "=== 提取完成 ==="
        wc -l CN.txt

        # 防止空文件（关键保护）
        if [ ! -s CN.txt ]; then
          echo "❌ 错误：没有提取到任何 IPv4 地址"
          exit 1
        fi

    - name: Generate RSC File
      run: |
        cd work

        {
        echo "/ip firewall address-list"
        awk '{print "add list=CN address="$1" comment=auto"}' CN.txt
        } > ../CN.rsc

        echo "=== 生成完成 ==="
        head -n 5 ../CN.rsc

    - name: Commit and Push
      run: |
        git config --global user.name "github-actions"
        git config --global user.email "actions@github.com"

        git add CN.rsc

        git commit -m "auto update CN IPv4 list" || echo "no changes"

        git push
