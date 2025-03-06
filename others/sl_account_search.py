import requests
import re

def search():

  num = 1
  global next_page

  url = 'https://search.secondlife.com/?page='+str(next_page)+'&search_type=standard&places_category=&destinations_category=0&collection_chosen=people&events_category=0&date=&dateformat=mm%2Fdd%2Fyy&starttime=0000&maturity=g&query_term='+ input_search +'&sort='

  uuid_pattern = '(?:\\{{0,1}(?:[0-9a-fA-F]){8}-(?:[0-9a-fA-F]){4}-(?:[0-9a-fA-F]){4}-(?:[0-9a-fA-F]){4}-(?:[0-9a-fA-F]){12}\\}{0,1})'

  page = requests.get(url)
  get_uuid = re.findall(uuid_pattern,page.text)

  uuid = list(set(get_uuid))

  for i in range(len(uuid)):      
    
    check_resident = requests.get('https://world.secondlife.com/resident/'+uuid[i])
    valid = re.findall('Page Not Found',check_resident.text)
    
    if not valid:
     
      get_name = re.findall(r'''<h1 [A-Za-z]+="[A-Za-z0-9]+">\s+<span>(.*?)<\s*\/\s*span>''',check_resident.text)
      
      if int(option) == 1:
          print('[ '+get_name[0]+' ] secondlife:///app/agent/'+uuid[i]+'/about')
      if int(option) == 2:
          print('[ '+get_name[0]+' ] https://world.secondlife.com/resident/'+uuid[i])
      if int(option) == 3:
          print(uuid[i]+'='+get_name[0])
      
      num = num + 1
      
      if(num>=19):
        
        next_page = next_page + 1
        search()

if __name__ == '__main__':

  next_page = 1
  input_search = input('enter keyword >>> ')
  option = input('[1] app.agent\n[2] world.secondlife\n[3] uuid\noption >>> ')
  search()
