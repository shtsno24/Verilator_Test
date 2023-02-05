import copy
import datetime


def find_resultlines(target: str, data: list) -> list:
    return [x for x in data if target in x]


def convert2timedelta(result: str):
    minsec_data = result.split("\t")[1]
    minute = int(minsec_data.split("m")[0])
    second = int(minsec_data.split("m")[1][:-1].split(".")[0])
    millisecond = int(minsec_data.split("m")[1][:-1].split(".")[1])
    return datetime.timedelta(seconds=minute * 60 + second, milliseconds=int(millisecond))


if __name__ == "__main__":
    test_longs = 1000
    csv_fname = "speed_log_{}.csv".format(test_longs)
    # read log files
    time_mode = ["real", "user", "sys"]
    with open("compile_run_cpp.log", "r") as cpp_f:
        data_cpp = cpp_f.read().splitlines()
    with open("compile_run_verilog.log", "r") as verilog_f:
        data_verilog = verilog_f.read().splitlines()

    # extract time data from log files
    records = {"cpp": data_cpp, "verilog": data_verilog}
    for k, v in copy.deepcopy(records).items():
        _time_data = {}
        for t in time_mode:
            _time_data[t] = find_resultlines(t, v)
        records[k] = _time_data

    for k, v in records.items():
        print(k)
        for i in time_mode:
            print(v[i])
        print("\n")

    # convert extracted time data to time object
    for k, v in copy.deepcopy(records).items():
        for _k, _v in v.items():
            records[k][_k] = [convert2timedelta(x) for x in _v]

    for k, v in records.items():
        print(k)
        for i in time_mode:
            print(v[i])
        print("\n")

    # export time object as csv
    with open(csv_fname, "w") as cf:
        header = "test_longs,Verilator_{0},Verilator_{1},Verilator_{2},Verilog_{0},Verilog_{1},Verilog_{2}\n".format(*time_mode)
        cf.write(header)
        cpp_recode = records["cpp"]
        verilog_recode = records["verilog"]
        for i in range(len(cpp_recode["real"])):
            cpp_results = "{},{},{}".format(*[cpp_recode[x][i].total_seconds() for x in time_mode])
            verilog_results = "{},{},{}".format(*[verilog_recode[x][i].total_seconds() for x in time_mode])
            single_recode = "{},{},{}\n".format(test_longs, cpp_results, verilog_results)
            cf.write(single_recode)
