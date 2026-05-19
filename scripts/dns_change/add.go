package main

import (
 "bufio"
 "fmt"
 "os"
 "strings"
 "os/exec"
 "runtime"
)

var domains = []string{
 "ultradent72.ru",
 "ultradent66.ru",
 "phpmyadmin.loc",
}

func getOs() string {
    return runtime.GOOS
}

func getHostPath() string {
    if (getOs() == "windows") {
        return "C:\\Windows\\System32\\drivers\\etc\\hosts";
    }

    if (getOs() == "linux") {
        return "/etc/hosts";
    }

    return "";
}

// Функция для добавления записи в файл hosts
func addEntry(domain string) error {
 hostPath := getHostPath()

 file, err := os.OpenFile(hostPath, os.O_APPEND|os.O_WRONLY|os.O_CREATE, 0644)
 if err != nil {
  return err
 }
 defer file.Close()

 _, err = file.WriteString("127.0.0.1 " + domain + "\n")
 return err
}

// Функция для проверки существования записи
func entryExists(domain string) (bool, error) {
 hostPath := getHostPath()
 file, err := os.Open(hostPath)
 if err != nil {
  return false, err
 }
 defer file.Close()

 scanner := bufio.NewScanner(file)
 for scanner.Scan() {
  line := scanner.Text()
  if strings.Contains(line, domain) {
   return true, nil
  }
 }

 return false, scanner.Err()
}

// Функция для добавления всех записей
func addEntries() error {
 for _, domain := range domains {
  exists, err := entryExists(domain)
  if err != nil {
   return err
  }

  if !exists {
   fmt.Printf("Записи для %s не существует. Добавление...\n", domain)
   if err := addEntry(domain); err != nil {
    return err
   }
  } else {
   fmt.Printf("Запись для %s уже существует.\n", domain)
  }
 }
 return nil
}

func flushDnsWin() {
 command := exec.Command("cmd", "/C", "ipconfig", "/flushdns")

 err := command.Run()
 if err != nil {
  fmt.Printf("Ошибка при выполнении команды: %s\n", err)
  return
 }

 fmt.Println("DNS кеш очищен")
}

func flushDnsLinux() {
 command := exec.Command("sudo", "systemd-resolve", "--flush-caches")

 err := command.Run()
 if err != nil {
  fmt.Printf("Ошибка при выполнении команды: %s\n", err)
  return
 }

 fmt.Println("DNS кеш очищен")
}

func flushDns() {
    if(getOs() == "windows") {
        flushDnsWin()
    }
    if(getOs() == "linux") {
        flushDnsLinux()
    }
}

func main() {
 err := addEntries()

 flushDns();

 if err != nil {
  fmt.Println("Ошибка:", err)
 } else {
  fmt.Println("Записи успешно добавлены.")
 }
}