#!/bin/bash

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root. Please run 'sudo -i' and then execute this script again."
   exit 1
fi

# Function to display menu
display_menu() {
    echo "================================"
    echo "ORE V2 一键挖矿脚本  By:Doge"
    echo "================================"
    echo "1. 安装ORE节点"
    echo "2. 生成钱包"
    echo "3. 领水"
    echo "4. 查看余额"
    echo "5. 查询本机算力"
    echo "6. 查看当前私钥"
    echo "7. 删除当前钱包"
    echo "8. 退出脚本"
    echo "9. 开始挖矿"
    echo "0. 后台挖矿"
    echo "==============================="
}

# Function to install ORE node
install_ore_node() {
    echo "Installing ORE node..."
    echo y | apt install cargo
    echo y | apt install git
    echo y | apt install curl

    curl https://sh.rustup.rs -sSf | sh -s -- -y

    sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
    export PATH="/root/.local/share/solana/install/active_release/bin:$PATH"

    solana config set --url d

    git clone https://github.com/hardhatchad/ore
    git clone https://github.com/hardhatchad/ore-cli
    git clone https://github.com/hardhatchad/drillx

    cd ore && git checkout hardhat/devnet-prerelease && cd ..
    cd ore-cli && git checkout hardhat/devnet-prerelease && . "$HOME/.cargo/env"
    cargo build --release && cd ..

    echo "节点已安装完成。按任意键返回脚本"
    read -n 1 -s -r -p ""
}

# Function to generate wallet
generate_wallet() {
    if [[ -f "/root/.config/solana/id.json" ]]; then
        read -p "当前存在钱包文件，是否替换？(y/n): " replace_choice
        if [[ $replace_choice == "y" || $replace_choice == "Y" ]]; then
            solana-keygen new -o /root/.config/solana/id.json --force
            echo "钱包文件已替换"
        else
            echo "未替换钱包文件"
        fi
    else
        solana-keygen new -o /root/.config/solana/id.json
        echo "已创建新钱包文件"
    fi
    read -n 1 -s -r -p "按任意键返回脚本"
}

# Main script
while true; do
    display_menu

    read -p "请输入选项: " choice
    case $choice in
        1) install_ore_node ;;
        2) generate_wallet ;;
        3) solana airdrop 1 ; read -n 1 -s -r -p "按任意键返回脚本" ;;
        4) ./ore-cli/target/release/ore balance ; read -n 1 -s -r -p "按任意键返回脚本" ;;
        5) ./ore-cli/target/release/ore benchmark ; read -n 1 -s -r -p "按任意键返回脚本" ;;
        6) cat /root/.config/solana/id.json ; read -n 1 -s -r -p "按任意键返回脚本" ;;
        7) read -p "是否确定删除当前私钥？(y/n): " confirm
           if [[ $confirm == "y" || $confirm == "Y" ]]; then
               rm -rf /root/.config/solana/id.json
               echo "私钥已删除"
           else
               echo "已取消删除"
           fi
           read -n 1 -s -r -p "按任意键返回脚本" ;;
        8) echo "退出脚本。"; break ;;
        9) ./ore-cli/target/release/ore mine --keypair /root/.config/solana/id.json --threads 8 --rpc https://api.devnet.solana.com ; read -n 1 -s -r -p "按任意键返回脚本" ;;
        0) nohup ./ore-cli/target/release/ore mine --keypair /root/.config/solana/id.json --threads 8 --rpc https://api.devnet.solana.com & echo "后台挖矿中"; read -n 1 -s -r -p "按任意键返回脚本" ;;
        *) echo "无效的选项，请重新输入" ;;
    esac
done
