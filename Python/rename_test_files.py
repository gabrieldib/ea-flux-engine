import os
import shutil
import pprint

FLUX_SAMPLES = "E:\Dropbox\emergence audio - gabriel\From Emergence Audio\Flux Test Samples\Flux Mapping Test Samples"

'''
File name convention:
    Product_Group_RootNote_VelocityIndex_RoundRobinIndex
'''

files_data = []
for root, dirs, files in os.walk(FLUX_SAMPLES):
    for file in files:
        if file.endswith(".wav"):
            files_data.append({"file_path": root, "file_name": file})


def add_to_test_samples(item, group, index, velo, rr):
    file_name = f"Flux_{group}_{index+48}_{velo}_{rr}.wav"
    file_path =  item["file_path"]
    full_path = os.path.join(file_path, file_name)
    source = os.path.join(file_path, item["file_name"])
    test_samples[group].append({"full_path":full_path, "source":source})

group_names = [
    "apple",
    "banana",
    "kiwi",
    "orange",
    "mango"
]

test_samples = {
    "apple":[],
    "banana":[],
    "kiwi":[],
    "orange":[],
    "mango":[],
}

for index, item in enumerate(files_data):
    for velo in range(1,5):
        for rr in range(1,4):
            for name in group_names:
                add_to_test_samples(item, name, index, velo, rr)
            

for item in test_samples:
    for duo in test_samples[item]:
        if not os.path.exists(duo["full_path"]):
            print(f"Copying {duo['source']} to {duo['full_path']}")
            shutil.copy(duo["source"], duo["full_path"])
        else:
            print(f"File already exists: {duo['full_path']}")