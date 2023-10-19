import websockets
import asyncio

connected_clients = set()
server_ip = "192.168.68.61" #insert local IP address
server_port = 3000

async def echo(websocket, path):
    """
    After receive message from client, boardcast that message to every clients
    
    Args:
        websocket：WebSocket connection
        path：the path client will connect to
    """

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

start_server = websockets.serve(echo, server_ip, server_port) # use echo function to handle server incoming conection

async def main():
    await start_server

if __name__ == "__main__":
    asyncio.get_event_loop().run_until_complete(main())  # looping to keep receiving message
    asyncio.get_event_loop().run_forever()
