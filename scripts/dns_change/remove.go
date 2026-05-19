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
 if getOs() == "windows" {
  return "C:\\Windows\\System32\\drivers\\etc\\hosts"
 }
 if getOs() == "linux" {
  return "/etc/hosts"
 }
 return ""
}

// Функция для удаления записи из файла hosts
func removeEntry(domain string) error {
 hostPath := getHostPath()

 file, err := os.Open(hostPath)
 if err != nil {
  return err
 }
 defer file.Close()

 var lines []string
 scanner := bufio.NewScanner(file)
 for scanner.Scan() {
  line := scanner.Text()
  if !strings.Contains(line, domain) {
   lines = append(lines, line) // Добавляем строку, если она не содержит домен
  }
 }

 if err := scanner.Err(); err != nil {
  return err
 }

 // Записываем обратно все строки, кроме удаляемых
 file, err = os.OpenFile(hostPath, os.O_TRUNC|os.O_WRONLY, 0644)
 if err != nil {
  return err
 }
 defer file.Close()

 for _, line := range lines {
  if _, err := file.WriteString(line + "\n"); err != nil {
   return err
  }
 }

 return nil
}

// Функция для удаления всех записей
func removeEntries() error {
 for _, domain := range domains {
  fmt.Printf("Удаление записи для %s...\n", domain)
  if err := removeEntry(domain); err != nil {
   return err
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
 if getOs() == "windows" {
  flushDnsWin()
 }
 if getOs() == "linux" {
  flushDnsLinux()
 }
}

func main() {
 err := removeEntries()
 if err != nil {
  fmt.Println("Ошибка:", err)
 } else {
  fmt.Println("Записи успешно удалены.")
 }

 flushDns()
}
