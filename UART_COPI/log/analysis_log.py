import matplotlib.pyplot as plt
import numpy as np
import csv
import copy

if __name__ == "__main__":
    # read log data
    with open("speed_log.csv", "r") as f:
        reader = csv.reader(f)
        header = next(reader)
        reader_list = [x for x in reader]

    print(header)
    mean_dict = {}
    for row in reader_list:
        key = mean_dict.keys()
        if row[0] not in key:
            mean_dict[row[0]] = [row[1:]]
        else:
            mean_dict[row[0]].append(row[1:])

    # reshape log data
    for k, v in copy.deepcopy(mean_dict).items():
        mean_dict[k] = list(zip(*v))
    for k, v in copy.deepcopy(mean_dict).items():
        mean_dict[k] = [np.array([float(x) for x in y]) for y in v]

    # calc mean and std
    std_dict = dict(zip(header[1:], [[] for x in range(len(header[1:]))]))
    _mean_dict = dict(zip(header[1:], [[] for x in range(len(header[1:]))]))
    with open("analysis_result.log", "w") as f:
        for k, v in mean_dict.items():
            print(k)
            f.write("{}\n".format(k))
            for i in zip(v, header[1:]):
                print("{} : {} +- {}".format(i[1], np.mean(i[0]), 3 * np.std(i[0])))
                f.write("    {} : mean    = {}\n".format(i[1], np.mean(i[0])))
                f.write("    {} : 3 * std = {}\n".format(" " * len(i[1]), 3 * np.std(i[0])))
                std_dict[i[1]].append(3 * np.std(i[0]))
                _mean_dict[i[1]].append(np.mean(i[0]))
            print()
            f.write("\n")

    # plot data
    x_axis_data = mean_dict.keys()
    print(std_dict)
    print(_mean_dict)
    print(x_axis_data)

    plt.figure(figsize=(16, 9))

    for k in header[1:]:
        plt.errorbar(x_axis_data, _mean_dict[k], yerr=std_dict[k], capsize=5, fmt='-o', markersize=10, label=k)

    plt.yscale('log')
    plt.xlabel('total timesteps', fontsize=20)
    plt.ylabel('average run time[s]', fontsize=20)
    plt.legend(loc='upper left')
    plt.savefig('analysis_result_log.png')

    plt.yscale('linear')
    plt.savefig('analysis_result_linear.png')
