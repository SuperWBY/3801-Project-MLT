import websockets
import asyncio

connected_clients = set()
server_ip = "192.168.68.53" #输入本地的IP
server_port = 3000  

async def echo(websocket, path):
    connected_clients.add(websocket)
    try:
        while True:
            async for message in websocket:
                print(f"Received message from client: {message}")
                respons = f"Server received: {message}"
                for client in connected_clients:
                    await client.send(respons) 
                   
               
    except websockets.exceptions.ConnectionClosed:
        print("Client disconnected")
    finally:
        connected_clients.remove(websocket)

start_server = websockets.serve(echo, server_ip, server_port)

async def main():
    await start_server

if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(main())  # 启动事件循环
    asyncio.get_event_loop().run_forever()
